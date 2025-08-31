// Windows-spezifische Named-Pipe-Implementierung.
//
// Zweck: TS‑Bytestrom (H.264 in MPEG‑TS) in eine Named Pipe schreiben,
// damit der media_kit/mpv‑Player die Daten als Live‑Quelle lesen kann.
//
// ⚠️ Funktioniert nur unter Windows. Unter anderen Plattformen bitte
// alternative IPC (z. B. TCP‑Socket) oder Datei‑Pufferung verwenden.

import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class WindowsNamedPipeWriter {
  final String name;
  int _hPipe = INVALID_HANDLE_VALUE;
  bool _connected = false;

  WindowsNamedPipeWriter(this.name);

  /// Erstellt den Pipe‑Server und wartet auf Verbindung durch den Client.
  Future<void> connectAsync() async {
    _hPipe = await Isolate.run<int>(() {
      final pName = TEXT(name);
      final h = CreateNamedPipe(
        pName,
        PIPE_ACCESS_OUTBOUND | FILE_FLAG_FIRST_PIPE_INSTANCE,
        PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
        1,
        4 * 1024 * 1024,
        4 * 1024 * 1024,
        0,
        ffi.nullptr,
      );
      calloc.free(pName);
      final lastErr = GetLastError();
      if (h == INVALID_HANDLE_VALUE) {
        throw Exception('CreateNamedPipe failed: $lastErr');
      }
      final ok = ConnectNamedPipe(h, ffi.nullptr);
      if (ok == 0 && GetLastError() != ERROR_PIPE_CONNECTED) {
        final err = GetLastError();
        CloseHandle(h);
        throw Exception('ConnectNamedPipe failed: $err');
      }
      return h;
    });
    _connected = true;
  }

  /// Schreibt Rohbytes in die Pipe. Robust gegenüber Disconnects.
  void write(Uint8List data) {
    if (!_connected) return;
    final p = calloc<ffi.Uint8>(data.length);
    try {
      p.asTypedList(data.length).setAll(0, data);
      final written = calloc<ffi.Uint32>();
      final ok = WriteFile(_hPipe, p, data.length, written, ffi.nullptr);
      calloc.free(written);
      if (ok == 0) {
        final err = GetLastError();
        if (err == ERROR_BROKEN_PIPE || err == ERROR_NO_DATA) {
          _connected = false; // Client hat getrennt – still fallen lassen
          return;
        }
        throw Exception('WriteFile failed: $err');
      }
    } finally {
      calloc.free(p);
    }
  }

  void close() {
    if (_hPipe != INVALID_HANDLE_VALUE) {
      try {
        FlushFileBuffers(_hPipe);
      } catch (_) {}
      try {
        DisconnectNamedPipe(_hPipe);
      } catch (_) {}
      try {
        CloseHandle(_hPipe);
      } catch (_) {}
      _hPipe = INVALID_HANDLE_VALUE;
    }
    _connected = false;
  }
}