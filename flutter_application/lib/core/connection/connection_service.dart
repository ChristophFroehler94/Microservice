// lib/core/connection/connection_service.dart
// Baut gRPC-Channel mit TLS (mkcert-Root-CA), erkennt Diensttyp,
// und ruft HTTPS-Metrics-Endpoints über einen HttpClient mit mkcert-Root-CA ab.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:grpc/grpc.dart';
import 'package:http/io_client.dart';

import '../../shared/model/service_kind.dart';
import '../../core/consul/consul_discovery.dart';
import '../../core/grpc/grpc_channel.dart';

// gRPC Stubs
import '../../src/generated/camera.pbgrpc.dart';
import '../../src/generated/flashcontrol.pbgrpc.dart' as pol;

class ConnectionService {
  ConnectionService({
    required List<int> grpcCaPem,            // mkcert Root-CA für gRPC/Kestrel
    String? authorityOverride,               // optionaler DNS-Name (SNI/:authority) – bei IP+SAN nicht nötig
    void Function(String msg)? onLog,
  })  : _onLog = onLog,
        _grpcCaPem = grpcCaPem,
        _authority = authorityOverride;

  final void Function(String msg)? _onLog;
  final List<int> _grpcCaPem;
  final String? _authority;

  ClientChannel? _channel;
  ServiceKind? _kind;
  CameraServiceClient? _camera;
  pol.FlashControlClient? _flash;
  ConsulInstance? _instance;
  String? _selectedServiceName;

  ServiceKind? get kind => _kind;
  CameraServiceClient? get camera => _camera;
  pol.FlashControlClient? get flash => _flash;
  ConsulInstance? get instance => _instance;
  String? get selectedServiceName => _selectedServiceName;
  String? get authorityUsed => _authority;

  Future<void> connect({
    required ConsulInstance instance,
    required String selectedServiceName,
  }) async {
    await _channel?.shutdown();

    _camera = null;
    _flash = null;
    _kind = null;

    final channel = GrpcChannelFactory.secure(
      instance.host,
      instance.port,
      trustedCaPem: _grpcCaPem,   // Root-CA für diesen gRPC-Channel
      authority: _authority,      // nur setzen, wenn DNS genutzt werden soll
    );

    final name = selectedServiceName.toLowerCase();
    final tagsLower = instance.tags.map((t) => t.toLowerCase()).toList();

    final isPolFlash = tagsLower.contains('polflash') ||
        tagsLower.contains('svc:polflash') ||
        name.contains('polflash');

    _channel = channel;
    _instance = instance;
    _selectedServiceName = selectedServiceName;

    if (isPolFlash) {
      _kind = ServiceKind.polflash;
      _flash = pol.FlashControlClient(channel);
    } else {
      _kind = ServiceKind.camera;
      _camera = CameraServiceClient(channel);
    }
  }

  void log(String msg) => _onLog?.call(msg);

  Future<void> dispose() async {
    try { await _channel?.shutdown(); } catch (_) {}
  }

  // ---- HTTPS-Client mit mkcert-Root-CA (für Metrics-Endpoints) ----

  IOClient _httpClientForGrpcCa() {
    final ctx = SecurityContext(withTrustedRoots: false);
    // Nur der angegebenen CA vertrauen
    ctx.setTrustedCertificatesBytes(_grpcCaPem);
    final hc = HttpClient(context: ctx)
      ..connectionTimeout = const Duration(seconds: 8)
      ..idleTimeout = const Duration(seconds: 15)
      ..badCertificateCallback = (cert, host, port) => false; // nichts durchwinken
    return IOClient(hc);
  }

  /// Ruft `/metrics/snapshot` (JSON) der aktiven Instanz über HTTPS ab.
  Future<Map<String, dynamic>> fetchMetricsSnapshot() async {
    final inst = _instance ?? (throw StateError('Keine aktive Verbindung.'));
    final uri = Uri(scheme: 'https', host: inst.host, port: inst.port, path: '/metrics/snapshot');

    final http = _httpClientForGrpcCa();
    try {
      final resp = await http.get(uri);
      if (resp.statusCode != 200) {
        throw HttpException('GET ${uri.path} -> HTTP ${resp.statusCode}');
      }
      final body = json.decode(resp.body);
      if (body is Map<String, dynamic>) return body;
      throw const FormatException('Unerwartetes JSON-Format.');
    } finally {
      http.close();
    }
  }

  /// Versucht fortgeschrittene Medicam-Metriken:
  /// - /metrics/extras (empfohlen)
  /// - /diag/quantiles (Fallback – lokaler Quantils-Schnappschuss)
  Future<Map<String, dynamic>?> tryFetchAdvancedMetrics() async {
    final inst = _instance ?? (throw StateError('Keine aktive Verbindung.'));
    final http = _httpClientForGrpcCa();
    try {
      for (final path in const ['/metrics/extras', '/diag/quantiles']) {
        final uri = Uri(scheme: 'https', host: inst.host, port: inst.port, path: path);
        try {
          final resp = await http.get(uri);
          if (resp.statusCode == 200) {
            final body = json.decode(resp.body);
            if (body is Map<String, dynamic>) return body;
          }
        } catch (_) {
          // nächster Pfad wird versucht
        }
      }
      return null;
    } finally {
      http.close();
    }
  }
}
