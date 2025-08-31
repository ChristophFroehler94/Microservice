import 'package:flutter/foundation.dart';

/// Hält die letzten N Log-Zeilen in einem ValueNotifier 'String'.
class LogBuffer {
  final int max;
  final _lines = <String>[];
  final ValueNotifier<String> notifier = ValueNotifier<String>('');

  LogBuffer({this.max = 500});

  void append(String m) {
    _lines.add(m);
    if (_lines.length > max) {
      _lines.removeRange(0, _lines.length - max);
    }
    notifier.value = _lines.join('\n');
  }
}