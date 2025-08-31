import 'package:flutter/material.dart';
import 'app/app.dart';


/// Einstiegspunkt der Flutter‑App.
///
/// Keine Business-Logik hier – die App-Shell kapselt Setup & UI.
void main() {
WidgetsFlutterBinding.ensureInitialized();
runApp(const App());
}