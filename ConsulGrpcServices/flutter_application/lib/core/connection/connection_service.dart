import 'dart:async';
import 'package:grpc/grpc.dart';

import '../../shared/model/service_kind.dart';
import '../../core/consul/consul_discovery.dart';
import '../../core/grpc/grpc_channel.dart';

// gRPC Stubs
import '../../src/generated/camera.pbgrpc.dart';
import '../../src/generated/flashcontrol.pbgrpc.dart' as pol;

/// Baut & hält die gRPC-Verbindung und stellt
/// je nach Service die passenden Clients bereit.
class ConnectionService {
  ConnectionService({
    required List<int> caPem,
    void Function(String msg)? onLog,
  })  : _onLog = onLog,
        _caPem = caPem;

  final void Function(String msg)? _onLog;
  final List<int> _caPem;

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
      caPem: _caPem,
      // authority: 'optional.example.internal', // nur falls nötig
    );

    final name = (selectedServiceName).toLowerCase();
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
