// lib/main.dart
// Einstiegspunkt: reine Bootstrap-Weiterleitung in die App-Shell.

import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
