// lib/src/consul_discovery.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

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

  @override
  String toString() => '$host:$port  [$id]  ${tags.isEmpty ? "" : tags.join(",")}';
}

/// Minimaler Consul-Client für Discovery.
class ConsulDiscovery {
  final Uri consulBase;
  final Random _rng = Random();

  ConsulDiscovery(String consulAddress)
      : consulBase = Uri.parse(
          consulAddress.endsWith('/')
              ? consulAddress.substring(0, consulAddress.length - 1)
              : consulAddress);

  static const _timeout = Duration(seconds: 3);

  /// Liefert alle Service-Namen (optional nach Tag gefiltert).
  Future<List<String>> listServices({String? tag}) async {
    final uri = consulBase.replace(path: '${consulBase.path}/v1/catalog/services');
    final resp = await http.get(uri).timeout(_timeout);
    if (resp.statusCode != 200) {
      throw Exception('Consul HTTP ${resp.statusCode}: ${resp.body}');
    }
    final Map<String, dynamic> map = json.decode(resp.body) as Map<String, dynamic>;
    final all = map.keys.toList()..sort();
    if (tag == null || tag.isEmpty) return all;

    final filtered = <String>[];
    map.forEach((name, tags) {
      if (tags is List && tags.contains(tag)) filtered.add(name);
    });
    filtered.sort();
    return filtered;
  }

  /// Liefert nur **gesunde** Instanzen (passing checks) eines Services.
  Future<List<ConsulInstance>> listHealthyInstances({
    required String serviceName,
    String? tag,
  }) async {
    final q = <String, String>{'passing': 'true'};
    if (tag != null && tag.isNotEmpty) q['tag'] = tag;

    final uri = consulBase.replace(
      path: '${consulBase.path}/v1/health/service/$serviceName',
      queryParameters: q,
    );

    final resp = await http.get(uri).timeout(_timeout);
    if (resp.statusCode != 200) {
      throw Exception('Consul HTTP ${resp.statusCode}: ${resp.body}');
    }
    final List<dynamic> rows = json.decode(resp.body) as List<dynamic>;
    final list = <ConsulInstance>[];
    for (final e in rows) {
      final svc = e['Service'] as Map<String, dynamic>;
      final node = e['Node'] as Map<String, dynamic>;
      final addr = (svc['Address'] as String?)?.trim();
      final nodeAddr = (node['Address'] as String?)?.trim();
      final host = (addr != null && addr.isNotEmpty) ? addr : (nodeAddr ?? 'localhost');
      final port = (svc['Port'] as num?)?.toInt() ?? 0;
      if (port <= 0) continue;
      final id = (svc['ID'] as String?) ?? '';
      final tags = (svc['Tags'] as List?)?.map((x) => x.toString()).toList() ?? const <String>[];
      list.add(ConsulInstance(id: id, host: host, port: port, tags: tags));
    }
    return list;
  }

  /// Zufällige gesunde Instanz (optional weiter nutzen).
  Future<({String host, int port})> findService({
    required String serviceName,
    String? tag,
  }) async {
    final instances = await listHealthyInstances(serviceName: serviceName, tag: tag);
    if (instances.isEmpty) {
      throw Exception('Keine gesunden Instanzen für "$serviceName"${tag != null ? ' (tag=$tag)' : ''}.');
    }
    final pick = instances[_rng.nextInt(instances.length)];
    return (host: pick.host, port: pick.port);
  }
}
