// lib/core/consul/consul_discovery.dart
// TLS-gesicherte Consul-Discovery (HTTPS): listet Services und gesunde Instanzen.
// Nutzt /v1/catalog/services und /v1/health/service/<name>?passing=true
// mit optionalem serverseitigem Filter (Service.Tags contains "...").

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/io_client.dart';

/// Einzelne (gesunde) Service-Instanz aus Consul.
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

class ConsulDiscovery {
  final Uri base;
  final IOClient _http;
  final String? token;
  final _rng = Random();

  /// [baseUrl] z. B. `https://192.168.178.48:8501`
  /// [caPem]   Root-CA (PEM) der Consul-CA.
  /// [token]   optional (ACL).
  ConsulDiscovery(
    String baseUrl, {
    required List<int> caPem,
    this.token,
  })  : base = _normalizeBase(baseUrl),
        _http = IOClient(_httpClientForCa(caPem));

  static HttpClient _httpClientForCa(List<int> caPem) {
    final ctx = SecurityContext(withTrustedRoots: false);
    ctx.setTrustedCertificatesBytes(caPem); // TLS-Trust auf Consul-CA :contentReference[oaicite:5]{index=5}
    final hc = HttpClient(context: ctx)
      ..connectionTimeout = const Duration(seconds: 8)
      ..idleTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (cert, host, port) => false;
    return hc;
  }

  static Uri _normalizeBase(String raw) {
    final r = raw.trim();
    final parsed = Uri.tryParse(r);
    if (parsed == null) {
      throw ArgumentError('Ungültige Consul-URL: "$raw"');
    }
    return parsed.hasScheme ? parsed : Uri.parse('https://$r');
  }

  Map<String, String> get _headers => {
        if (token != null && token!.isNotEmpty) 'X-Consul-Token': token!,
      };

  /// Listet alle registrierten Services (optional lokal per Tag gefiltert).
  /// Nutzt: GET /v1/catalog/services  (liefert Map: { serviceName: [tags...] })
  Future<List<String>> listServices({String? tag}) async {
    final uri = base.replace(path: '/v1/catalog/services'); // Consul API: /catalog/services :contentReference[oaicite:6]{index=6}
    final resp = await _http.get(uri, headers: _headers);
    if (resp.statusCode != 200) {
      throw HttpException('Consul /catalog/services -> HTTP ${resp.statusCode}');
    }

    final map = json.decode(resp.body) as Map<String, dynamic>;
    final all = map.keys.toList()..sort();

    if (tag == null || tag.isEmpty) return all;

    // Lokal nach Tag filtern (Endpoint liefert Tags pro Service)
    final filtered = <String>[];
    map.forEach((name, tags) {
      if (tags is List && tags.cast<dynamic>().map((e) => '$e').contains(tag)) {
        filtered.add(name);
      }
    });
    filtered.sort();
    return filtered;
  }

  /// Liefert gesunde Instanzen eines Service-Namens.
  /// Nutzt: GET /v1/health/service/"name"?passing=true
  /// Optionaler Tag-Filter via serverseitigem Filter:
  ///   filter=Service.Tags contains "tag"
  Future<List<ConsulInstance>> listHealthyInstances({
    required String serviceName,
    String? tag,
  }) async {
    final q = <String, String>{'passing': 'true'};
    if (tag != null && tag.isNotEmpty) {
      final t = tag.replaceAll('"', r'\"');
      q['filter'] = 'Service.Tags contains "$t"'; // Consul Filtering-Feature :contentReference[oaicite:7]{index=7}
    }

    final uri = base.replace(
      path: '/v1/health/service/$serviceName',
      queryParameters: q,
    );

    final resp = await _http.get(uri, headers: _headers);
    if (resp.statusCode != 200) {
      throw HttpException('Consul /health/service/$serviceName -> HTTP ${resp.statusCode}');
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

  /// Zufällige gesunde Instanz.
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
