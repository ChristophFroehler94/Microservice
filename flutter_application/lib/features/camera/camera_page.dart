// lib/features/camera/camera_page.dart
// UI für Kamerasteuerung, nutzt gRPC-Client und CameraPlayer (Live/TS Save).

import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/connection/connection_service.dart';
import '../../shared/model/capture_profile.dart';
import '../../src/generated/camera.pbgrpc.dart';
import '../../src/generated/google/protobuf/empty.pb.dart' as wkt;
import 'camera_player.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.conn, required this.log, required this.profile});

  final ConnectionService conn;
  final ValueNotifier<String> log;
  final ValueNotifier<CaptureProfile> profile;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late final CameraPlayer _player;
  int _zoomPos = 0x2000; // Start-Mitte

  @override
  void initState() {
    super.initState();
    _player = CameraPlayer(
      conn: widget.conn,
      onLog: _appendLog,
      onStateChanged: _onPlayerStateChange,
    );
    _player.init();
  }

  void _onPlayerStateChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _setLog(String msg) => widget.log.value = msg;
  void _appendLog(String msg) => widget.log.value = '${widget.log.value}\n$msg';

  CameraServiceClient? get _client => widget.conn.camera;

  Future<void> _powerOn() async {
    if (_client == null) return;
    try {
      final r = await _client!.power(PowerRequest()..on = true);
      _setLog('Power: ok=${r.ok} msg=${r.message}');
    } catch (e) {
      _setLog('Power-Fehler: $e');
    }
  }

  Future<void> _setZoomPosition() async {
    if (_client == null) return;
    try {
      final rep = await _client!.zoom(ZoomRequest()..position = _zoomPos);
      _appendLog('Zoom gesetzt: ok=${rep.ok}');
    } catch (e) {
      _setLog('Zoom-Fehler: $e');
    }
  }

  Future<void> _getStatus() async {
    if (_client == null) return;
    try {
      final st = await _client!.getStatus(wkt.Empty());
      _setLog('Status: poweredOn=${st.poweredOn}, zoomPos=${st.zoomPos}');
      setState(() => _zoomPos = st.zoomPos);
    } catch (e) {
      _setLog('Status-Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile.value;

    return Column(
      children: [
        if (_player.controller != null)
          Expanded(
            flex: 3,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Video(controller: _player.controller!),
            ),
          ),
        const SizedBox(height: 12),

        // Zoom-Slider (0x0000 .. 0x7AC0)
        Row(
          children: [
            const Text('Zoom:'),
            Expanded(
              child: Slider(
                value: _zoomPos.toDouble(),
                min: 0,
                max: 0x7AC0.toDouble(),
                onChanged: (v) => setState(() => _zoomPos = v.round()),
              ),
            ),
            Text('0x${_zoomPos.toRadixString(16).toUpperCase()}'),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(onPressed: _client != null ? _powerOn : null, child: const Text('Power On')),
            ElevatedButton(onPressed: _client != null ? _setZoomPosition : null, child: const Text('Set Zoom')),
            ElevatedButton(onPressed: _client != null ? _getStatus : null, child: const Text('Get Status')),

            // TS Save
            ElevatedButton(
              onPressed: _client != null && !_player.isSaving
                  ? () => _player.startTsSave(profile: profile)
                  : null,
              child: const Text('Start TS Save'),
            ),
            ElevatedButton(
              onPressed: _client != null && _player.isSaving
                  ? () => _player.stopTsSave()
                  : null,
              child: const Text('Stop TS Save'),
            ),

            // Live
            ElevatedButton(
              onPressed: _client != null && !_player.isLive
                  ? () => _player.startLive(profile: profile)
                  : null,
              child: const Text('Start Live'),
            ),
            ElevatedButton(
              onPressed: _client != null && _player.isLive
                  ? () => _player.stopLive()
                  : null,
              child: const Text('Stop Live'),
            ),
          ],
        ),
      ],
    );
  }
}
