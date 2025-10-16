// Windows-only Named-Pipe Writer für Live-Playback (MPEG-TS) via media_kit/mpv.
// Verwendet aktuelle Top-Level-Konstanten aus package:win32 (keine deprecated Enums).

import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win32;

class WindowsNamedPipeWriter {
  final String name;
  int _hPipe = win32.INVALID_HANDLE_VALUE;
  bool _connected = false;

  WindowsNamedPipeWriter(this.name);

  /// Erstellt Pipe-Server und wartet auf Client-Verbindung.
  Future<void> connectAsync() async {
    _hPipe = await Isolate.run<int>(() {
      final pName = win32.TEXT(name);

      // dwOpenMode: ACCESS + Flags
      final openMode =
          win32.PIPE_ACCESS_OUTBOUND | // 1‑Richtung: Server -> Client
          win32.FILE_FLAG_FIRST_PIPE_INSTANCE; // failt, falls Pipe bereits existiert

      // dwPipeMode: Type/ReadMode/Wait (Byte‑Stream, Blocking, Byte‑Lesemodus)
      final pipeMode =
          win32.PIPE_TYPE_BYTE |
          win32.PIPE_READMODE_BYTE |
          win32.PIPE_WAIT;

      final h = win32.CreateNamedPipe(
        pName,
        openMode,
        pipeMode,
        1,                 // nMaxInstances
        4 * 1024 * 1024,   // nOutBufferSize
        4 * 1024 * 1024,   // nInBufferSize
        0,                 // nDefaultTimeOut
        ffi.nullptr,       // lpSecurityAttributes
      );

      calloc.free(pName);

      if (h == win32.INVALID_HANDLE_VALUE) {
        final lastErr = win32.GetLastError();
        throw Exception('CreateNamedPipe failed: $lastErr');
      }

      final ok = win32.ConnectNamedPipe(h, ffi.nullptr);
      // Hinweis: 0 + ERROR_PIPE_CONNECTED bedeutet *trotzdem* erfolgreich verbunden.
      // (Client war schneller zwischen CreateNamedPipe und ConnectNamedPipe)
      // Siehe Microsoft-Doku zu ConnectNamedPipe.
      if (ok == 0 && win32.GetLastError() != win32.ERROR_PIPE_CONNECTED) {
        final err = win32.GetLastError();
        win32.CloseHandle(h);
        throw Exception('ConnectNamedPipe failed: $err');
      }

      return h;
    });

    _connected = true;
  }

  /// Schreibt Rohbytes in die Pipe. Bricht leise ab bei Disconnect.
  void write(Uint8List data) {
    if (!_connected) return;

    final p = calloc<ffi.Uint8>(data.length);
    try {
      p.asTypedList(data.length).setAll(0, data);

      final written = calloc<ffi.Uint32>();
      final ok = win32.WriteFile(_hPipe, p, data.length, written, ffi.nullptr);
      calloc.free(written);

      if (ok == 0) {
        final err = win32.GetLastError();

        // Leiser Abbruch bei gebrochener Pipe oder leerem Puffer (Client weg)
        if (err == win32.ERROR_BROKEN_PIPE || err == win32.ERROR_NO_DATA) {
          _connected = false;
          return;
        }

        throw Exception('WriteFile failed: $err');
      }
    } finally {
      calloc.free(p);
    }
  }

  void close() {
    if (_hPipe != win32.INVALID_HANDLE_VALUE) {
      try { win32.FlushFileBuffers(_hPipe); } catch (_) {}
      try { win32.DisconnectNamedPipe(_hPipe); } catch (_) {}
      try { win32.CloseHandle(_hPipe); } catch (_) {}
      _hPipe = win32.INVALID_HANDLE_VALUE;
    }
    _connected = false;
  }
}
