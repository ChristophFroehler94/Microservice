import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/connection/connection_service.dart';
import '../../shared/model/capture_profile.dart';
import '../../src/generated/camera.pbgrpc.dart';
import '../../src/generated/google/protobuf/empty.pb.dart' as wkt;
import 'camera_player.dart';

/// Seite für Kamera-Steuerung und Video-Vorschau.
///
/// Die gRPC-Aufrufe sind klein und klar gehalten. Aufwändigere Logik (Streaming,
/// Player, Speicherung) liegt in `CameraPlayer`.
class CameraPage extends StatefulWidget {
  const CameraPage({super.key, required this.conn, required this.log, required this.profile});

  final ConnectionService conn;
  final ValueNotifier<String> log;
  final ValueNotifier<CaptureProfile> profile; // Dropdown-Auswahl aus der App-Shell

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late final CameraPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = CameraPlayer(
      conn: widget.conn,
      onLog: _appendLog,
      onStateChanged: _onPlayerStateChange, // << neu: UI-Update bei Statewechsel
    );
    _player.init();
  }

  void _onPlayerStateChange() {
    if (!mounted) return;
    setState(() {}); // << Buttons werden neu ausgewertet
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

  Future<void> _zoomTele() async {
    if (_client == null) return;
    try {
      await _client!.zoom(
        ZoomRequest()
          ..variable = (ZoomRequest_SidedSpeed()
            ..dir = ZoomRequest_SidedSpeed_Direction.TELE
            ..speed = 3),
      );
      _appendLog('Zoom-Tele gesendet');
    } catch (e) {
      _setLog('Zoom-Fehler: $e');
    }
  }

  Future<void> _setFocusAuto() async {
    if (_client == null) return;
    try {
      final rep = await _client!.setFocusMode(
        SetFocusModeRequest()..mode = SetFocusModeRequest_Mode.AUTO,
      );
      _setLog('Focus AUTO: ok=${rep.ok}');
    } catch (e) {
      _setLog('Focus-Fehler: $e');
    }
  }

  Future<void> _getStatus() async {
    if (_client == null) return;
    try {
      final st = await _client!.getStatus(wkt.Empty());
      _setLog('Status: poweredOn=${st.poweredOn}, zoomPos=${st.zoomPos}, focusPos=${st.focusPos}');
    } catch (e) {
      _setLog('Status-Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile.value;

    return Column(
      children: [
        // Video-Preview
        if (_player.controller != null)
          Expanded(
            flex: 3,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Video(controller: _player.controller!),
            ),
          ),
        const SizedBox(height: 12),

        // Steuerungs-Buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(onPressed: _client != null ? _powerOn : null, child: const Text('Power On')),
            ElevatedButton(onPressed: _client != null ? _zoomTele : null, child: const Text('Zoom Tele')),
            ElevatedButton(onPressed: _client != null ? _setFocusAuto : null, child: const Text('Focus AUTO')),
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
