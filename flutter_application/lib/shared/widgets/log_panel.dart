// lib/shared/widgets/log_panel.dart
// Einfaches Log-Panel (scrollbar, selektierbar).

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LogPanel extends StatelessWidget {
  const LogPanel({super.key, required this.text});

  final ValueListenable<String> text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: text,
        builder: (_, value, __) => SingleChildScrollView(
          child: SelectableText(value),
        ),
      ),
    );
  }
}
