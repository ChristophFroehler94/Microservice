import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // << für VoidCallback
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/connection/connection_service.dart';
import '../../shared/model/capture_profile.dart';
import '../../shared/platform/windows_named_pipe_writer.dart';
import '../../src/generated/camera.pbgrpc.dart';

/// Kapselt Live-Wiedergabe (Named Pipe → media_kit) und TS-Mitschnitt.
class CameraPlayer {
  CameraPlayer({
    required this.conn,
    required this.onLog,
    this.onStateChanged, // << neu
  });

  final ConnectionService conn;
  final void Function(String msg) onLog;
  final VoidCallback? onStateChanged; // << neu

  void _notify() => onStateChanged?.call(); // << neu

  // media_kit Player/Controller
  Player? _player;
  VideoController? _controller;

  // Stream-Subscriptions
  StreamSubscription<TsChunk>? _tsSaveSub;
  StreamSubscription<TsChunk>? _tsLiveSub;

  // Datei-I/O
  IOSink? _tsSink;
  File? _tsFile;

  // Named Pipe (Windows)
  static const String pipePath = r'\\.\pipe\medicam_ts';
  WindowsNamedPipeWriter? _pipe;

  // Player-Tuning einmalig anwenden
  bool _tuned = false;

  VideoController? get controller => _controller;
  bool get isSaving => _tsSaveSub != null;
  bool get isLive => _tsLiveSub != null;

  /// Initialisiert den Player (einmalig).
  Future<void> init() async {
    _player = Player();
    _controller = VideoController(_player!);
  }

  /// Gibt Ressourcen frei.
  Future<void> dispose() async {
    try { await _tsSaveSub?.cancel(); } catch (_) {}
    try { await _tsLiveSub?.cancel(); } catch (_) {}
    try { await _tsSink?.flush(); } catch (_) {}
    try { await _tsSink?.close(); } catch (_) {}
    try { _pipe?.close(); } catch (_) {}
    try { await _player?.dispose(); } catch (_) {}
  }

  StreamH264Request _buildReq(CaptureProfile p) => StreamH264Request()
    ..deviceId = p.deviceId
    ..width = p.w
    ..height = p.h
    ..fps = p.fps
    ..bitrate = p.bitrate;

  Future<void> _tunePlayer() async {
    if (_tuned || _player == null) return;
    final native = _player!.platform as NativePlayer;
    await native.command(['apply-profile', 'low-latency']);
    await native.setProperty('demuxer-lavf-format', 'mpegts');
    await native.setProperty('demuxer-lavf-buffersize', '16384');
    await native.setProperty('demuxer-lavf-probesize', '32768');
    await native.setProperty('demuxer-lavf-analyzeduration', '1');
    await native.setProperty('cache', 'no');
    await native.setProperty('demuxer-readahead-secs', '0');
    await native.setProperty('vd-lavc-threads', '0');
    await native.setProperty('untimed', 'yes'); // nur ohne Audio
    await native.setProperty('framedrop', 'vo');
    await native.setProperty('video-latency-hacks', 'yes');
    _tuned = true;
  }

  // --------------------- TS in Datei speichern ----------------------------
  Future<void> startTsSave({required CaptureProfile profile}) async {
    final camera = conn.camera;
    if (camera == null || _tsSaveSub != null) return;

    final filePath = await FilePicker.platform.saveFile(
      dialogTitle: 'TS speichern …',
      fileName: 'stream_${DateTime.now().millisecondsSinceEpoch}.ts',
      type: FileType.custom,
      allowedExtensions: const ['ts'],
    );
    final path = filePath ?? _defaultTsPath();

    try {
      _tsFile = File(path);
      _tsSink = _tsFile!.openWrite();

      final req = _buildReq(profile);
      int total = 0;
      _tsSaveSub = camera.streamTs(req).listen(
        (chunk) {
          total += chunk.data.length;
          _tsSink!.add(chunk.data);
          if (total % (1024 * 1024) < chunk.data.length) {
            onLog('TS geschrieben: ~${(total / (1024 * 1024)).toStringAsFixed(1)} MiB');
          }
        },
        onError: (e) async {
          try { await _tsSink?.flush(); } catch (_) {}
          try { await _tsSink?.close(); } catch (_) {}
          _tsSink = null;
          _tsSaveSub = null;
          onLog('TS-Stream Fehler: $e');
          _notify(); // << UI aktualisieren
        },
        onDone: () async {
          try { await _tsSink?.flush(); } catch (_) {}
          try { await _tsSink?.close(); } catch (_) {}
          _tsSink = null;
          _tsSaveSub = null;
          onLog('TS-Stream beendet. Datei: ${_tsFile?.path}');
          _notify(); // << UI aktualisieren
        },
        cancelOnError: true,
      );

      onLog('TS-Stream gestartet ➜ ${_tsFile!.path}');
      _notify(); // << isSaving wurde true
    } catch (e) {
      onLog('Start TS-Save Fehler: $e');
      try { await _tsSink?.close(); } catch (_) {}
      _tsSink = null;
      _tsSaveSub = null;
      _notify(); // << falls kurzzeitig gestartet hat
    }
  }

  Future<void> stopTsSave() async {
    try { await _tsSaveSub?.cancel(); } catch (_) {}
    _tsSaveSub = null;
    try { await _tsSink?.flush(); } catch (_) {}
    try { await _tsSink?.close(); } catch (_) {}
    _tsSink = null;
    onLog('TS-Stream gestoppt. Datei: ${_tsFile?.path}');
    _notify(); // << isSaving wurde false
  }

  String _defaultTsPath() => Platform.isWindows
      ? 'C:\\capture\\stream_${DateTime.now().millisecondsSinceEpoch}.ts'
      : '/tmp/stream_${DateTime.now().millisecondsSinceEpoch}.ts';

  // --------------------- Live-Playback ------------------------------------
  Future<void> startLive({required CaptureProfile profile}) async {
    final camera = conn.camera;
    if (camera == null || _tsLiveSub != null) return;

    try {
      await _tunePlayer();
      _pipe = WindowsNamedPipeWriter(pipePath);

      // Pipe-Server verbinden (nicht blockierend awaiten)
      final connectFuture = _pipe!.connectAsync();

      // Demuxer ist bereits in _tunePlayer() gesetzt
      await _player!.open(Media(pipePath), play: true);

      // Sicherstellen, dass die Pipe verbunden ist, bevor wir Daten pumpen
      await connectFuture;

      final native = _player!.platform as NativePlayer;
      final s = await native.getProperty('demuxer-cache-duration');
      final cache = double.tryParse(s) ?? 0.0;
      if (cache > 0.2) {
        await native.command(['drop-buffers']);
      }

      final req = _buildReq(profile);
      _tsLiveSub = camera.streamTs(req).listen(
        (chunk) => _pipe?.write(Uint8List.fromList(chunk.data)),
        onError: (e) async {
          onLog('Live-Fehler: $e');
          await stopLive();
          _notify(); // << isLive false
        },
        onDone: () async {
          onLog('Live beendet');
          await stopLive();
          _notify(); // << isLive false
        },
        cancelOnError: true,
      );

      onLog('Live-Playback gestartet (${profile.w}x${profile.h}@${profile.fps}, ~${(profile.bitrate/1e6).toStringAsFixed(1)} Mbit/s).');
      _notify(); // << isLive wurde true
    } catch (e) {
      onLog('Start Live Fehler: $e');
      await stopLive();
      // stopLive() ruft _notify() selbst
    }
  }

  Future<void> stopLive() async {
    try { await _tsLiveSub?.cancel(); } catch (_) {}
    _tsLiveSub = null;
    try { await _player?.pause(); } catch (_) {}
    try { await _player?.stop(); } catch (_) {}
    try { _pipe?.close(); } catch (_) {}
    _pipe = null; // Instanz bewusst freigeben
    onLog('Live-Playback gestoppt.');
    _notify(); // << isLive wurde false
  }
}
