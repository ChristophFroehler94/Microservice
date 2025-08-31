import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/io_client.dart';

/// Repräsentiert eine einzelne (gesunde) Service-Instanz aus Consul.
class ConsulInstance {
  final String id;
  final String host;
  final int port;
  final List<String> tags;

  ConsulInstance({
    required this.id,
    required this.host,
    required this.port,
    required this.tags,
  });
}

/// Consul-Discovery mit TLS (eigene Root-CA).
class ConsulDiscovery {
  final Uri base;
  final IOClient _http;
  final String? token;
  final _rng = Random();

  /// [baseUrl] wie `https://192.168.178.40:8501`
  /// [caPem]   = Bytes deiner Root-CA (z. B. aus Asset `consul-agent-ca.pem`).
  /// [token]   optional (ACL); für dich leer lassen.
  ConsulDiscovery(
    String baseUrl, {
    required List<int> caPem,
    this.token,
  })  : base = _normalizeBase(baseUrl),
        _http = IOClient(_httpClientForCa(caPem));

  // SecurityContext NUR mit deiner CA -> strenge Validierung
  static HttpClient _httpClientForCa(List<int> caPem) {
    final ctx = SecurityContext(withTrustedRoots: false);
    // CA ins Trust-Store des Clients laden
    ctx.setTrustedCertificatesBytes(caPem); // dart:io SecurityContext (TLS) :contentReference[oaicite:1]{index=1}

    final hc = HttpClient(context: ctx)
      ..connectionTimeout = const Duration(seconds: 8)
      ..idleTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (cert, host, port) {
        // Nichts durchwinken: Nur Zertifikate akzeptieren, die sich sauber
        // bis zu unserer CA validieren lassen.
        return false;
      };
    return hc;
  }

  static Uri _normalizeBase(String raw) {
    final r = raw.trim();
    final parsed = Uri.tryParse(r);
    if (parsed == null) {
      throw ArgumentError('Ungültige Consul-URL: "$raw"');
    }
    // HTTPS erzwingen, wenn kein Schema mitgegeben wurde
    if (!parsed.hasScheme) {
      return Uri.parse('https://$r');
    }
    return parsed;
  }

  Map<String, String> get _headers => {
        if (token != null && token!.isNotEmpty) 'X-Consul-Token': token!,
      };

  /// Listet alle registrierten Services (optional lokal per Tag gefiltert).
  ///
  /// Nutzt: GET /v1/catalog/services  (liefert Map: { serviceName: [tags...] })
  Future<List<String>> listServices({String? tag}) async {
    final uri = base.replace(path: '/v1/catalog/services'); // :contentReference[oaicite:2]{index=2}
    final resp = await _http.get(uri, headers: _headers);
    if (resp.statusCode != 200) {
      throw HttpException('Consul /catalog/services -> ${resp.statusCode}');
    }

    final map = json.decode(resp.body) as Map<String, dynamic>;
    final all = map.keys.toList()..sort();

    if (tag == null || tag.isEmpty) return all;

    // lokal nach Tag filtern (der Endpunkt liefert tags pro Service-Namen)
    final filtered = <String>[];
    map.forEach((name, tags) {
      if (tags is List &&
          tags.cast<dynamic>().map((e) => '$e').contains(tag)) {
        filtered.add(name);
      }
    });
    filtered.sort();
    return filtered;
  }

  /// Liefert **gesunde** Instanzen eines Service-Namens.
  ///
  /// Nutzt: GET /v1/health/service/name passing=true
  /// Optionaler Tag-Filter via Consul-Filter:  filter=Service.Tags contains "tag"
  Future<List<ConsulInstance>> listHealthyInstances({
    required String serviceName,
    String? tag,
  }) async {
    final q = <String, String>{'passing': 'true'}; // nur "passing" Checks :contentReference[oaicite:3]{index=3}
    if (tag != null && tag.isNotEmpty) {
      // Konsul-Filter-Syntax (Service.Tags contains "xyz") – serverseitig filtern
      // Docs: Filter-Ausdrücke in Consul HTTP API. 
      final t = tag.replaceAll('"', r'\"');
      q['filter'] = 'Service.Tags contains "$t"';
    }

    final uri = base.replace(
      path: '/v1/health/service/$serviceName',
      queryParameters: q,
    );

    final resp = await _http.get(uri, headers: _headers);
    if (resp.statusCode != 200) {
      throw HttpException('Consul /health/service/$serviceName -> ${resp.statusCode}');
    }

    final list = json.decode(resp.body) as List<dynamic>;
    final result = <ConsulInstance>[];
    for (final item in list) {
      final obj = (item as Map<String, dynamic>);
      final service = (obj['Service'] as Map<String, dynamic>);
      final checks = (obj['Checks'] as List<dynamic>).cast<Map<String, dynamic>>();

      final allPassing = checks.every((c) => c['Status'] == 'passing');
      if (!allPassing) continue;

      final address = (service['Address'] as String?)?.trim() ?? '';
      final host = address.isNotEmpty ? address : (service['Address'] as String? ?? '');
      final port = service['Port'] as int? ?? 0;
      final tags = ((service['Tags'] as List?) ?? const <dynamic>[])
          .map((e) => '$e')
          .toList();

      if (host.isEmpty || port == 0) continue;
      result.add(ConsulInstance(
        id: service['ID'] as String? ?? '',
        host: host,
        port: port,
        tags: tags,
      ));
    }
    return result;
  }

  /// Wählt zufällig eine gesunde Instanz.
  Future<({String host, int port})> findService({
    required String serviceName,
    String? tag,
  }) async {
    final instances = await listHealthyInstances(serviceName: serviceName, tag: tag);
    if (instances.isEmpty) {
      throw StateError('Keine gesunden Instanzen für "$serviceName"${tag != null ? ' (tag=$tag)' : ''}.');
    }
    final pick = instances[_rng.nextInt(instances.length)];
    return (host: pick.host, port: pick.port);
  }

  void dispose() {
    _http.close();
  }
}
