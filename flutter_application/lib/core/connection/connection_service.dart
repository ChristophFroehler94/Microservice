// lib/core/connection/connection_service.dart
import 'dart:async';
import 'package:grpc/grpc.dart';

import '../../shared/model/service_kind.dart';
import '../../core/consul/consul_discovery.dart';
import '../../core/grpc/grpc_channel.dart';

// gRPC Stubs
import '../../src/generated/camera.pbgrpc.dart';
import '../../src/generated/flashcontrol.pbgrpc.dart' as pol;

class ConnectionService {
  ConnectionService({
    required List<int> caPem,                 // nur Consul
    required List<int> grpcCertPem,          // Dev-Zertifikat MedicamService (PEM)
    String authorityOverride = 'localhost',  // passt zu Dev-Zertifikat
    void Function(String msg)? onLog,
  })  : _onLog = onLog,
        _consulCaPem = caPem,
        _grpcCertPem = grpcCertPem,
        _authority = authorityOverride;

  final void Function(String msg)? _onLog;
  final List<int> _consulCaPem;   // der Vollständigkeit halber aufbewahrt
  final List<int> _grpcCertPem;
  final String _authority;

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
      serverCertPem: _grpcCertPem,     // Zertifikatspinning
      authority: _authority,           // HTTP/2 :authority + TLS SNI auf "localhost"
    );

    final name = selectedServiceName.toLowerCase();
    final tagsLower = instance.tags.map((t) => t.toLowerCase()).toList();
    final isPolFlash = tagsLower.contains('svc:polflash') || name.contains('polflash');

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
}
