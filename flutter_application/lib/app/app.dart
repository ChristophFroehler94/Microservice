// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/connection/connection_service.dart';
import '../core/consul/consul_discovery.dart';
import '../shared/model/service_kind.dart';
import '../shared/model/capture_profile.dart';
import '../shared/log/log_buffer.dart';
import '../shared/widgets/log_panel.dart';

// Feature-Seiten lazy via deferred import
import '../features/camera/camera_page.dart' deferred as cam;
import '../features/flash/flash_page.dart' deferred as fl;

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _navKey = GlobalKey<NavigatorState>();

  ConnectionService? _conn;
  ConsulDiscovery? _discovery;
 _conn = ConnectionService
  // TLS-Material
  List<int>? _consulCaPem;
  List<int>? _grpcServerCertPem; // Dev-Zertifikat des MedicamService

  static const String kDefaultConsulUrl = 'https://192.168.178.48:8501';

  final _consulCtrl = TextEditingController(text: kDefaultConsulUrl);
  final _tagCtrl = TextEditingController(text: 'grpc');

  final ValueNotifier<CaptureProfile> _profile =
      ValueNotifier<CaptureProfile>(CaptureProfile.fullHd);

  bool _cameraLibLoaded = false;
  bool _flashLibLoaded = false;

  late final LogBuffer _logBuffer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    MediaKit.ensureInitialized();
    _logBuffer = LogBuffer(max: 500);

    () async {
      try {
        // 1) Consul-Root-CA pinnen
        final caData = await rootBundle.load('assets/consul-agent-ca.pem');
        _consulCaPem = caData.buffer.asUint8List();

        // 2) gRPC-Serverzertifikat (Dev-Zertifikat) pinnen
        final grpcData = await rootBundle.load('assets/medicam-dev-cert.pem');
        _grpcServerCertPem = grpcData.buffer.asUint8List();

        // 3) Services bauen
        _discovery = ConsulDiscovery(_effectiveConsulUrl(), caPem: _consulCaPem!);
        _conn = ConnectionService(
          caPem: _consulCaPem!,                // nur für Consul-HTTPS
          grpcCertPem: _grpcServerCertPem!,    // Dev-Zertifikat des MedicamService
          authorityOverride: 'localhost',      // SNI/Authority -> passt zum Dev-Cert CN/SAN
          onLog: _appendLog,
        );

        _logBuffer.append('TLS bereit: Consul(✅ CA) • gRPC(✅ Dev-Zertifikat, authority=localhost).');
      } catch (e) {
        _appendLog('TLS init failed: $e');
      } finally {
        if (mounted) setState(() {});
      }
    }();
  }

  @override
  void dispose() {
    _conn?.dispose();
    _discovery?.dispose();
    _profile.dispose();
    _consulCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _appendLog(String msg) {
    final now = DateTime.now().toIso8601String();
    _logBuffer.append('[$now] $msg');
  }

  Future<void> _ensureCameraLoaded() async {
    if (!_cameraLibLoaded) {
      await cam.loadLibrary();
      _cameraLibLoaded = true;
    }
  }

  Future<void> _ensureFlashLoaded() async {
    if (!_flashLibLoaded) {
      await fl.loadLibrary();
      _flashLibLoaded = true;
    }
  }

  String _effectiveConsulUrl() {
    final raw = _consulCtrl.text.trim();
    final candidate = raw.isEmpty ? kDefaultConsulUrl : raw;
    final uri = Uri.tryParse(candidate);
    return (uri?.hasScheme ?? false) ? candidate : 'https://$candidate';
  }

  Future<T?> _showDlg<T>(Widget child) {
    final ctx = _navKey.currentContext;
    if (ctx == null) return Future.value(null);
    return showDialog<T>(context: ctx, builder: (_) => child);
  }

  void _snack(String msg) {
    _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _browseAndConnect() async {
    if (_consulCaPem == null || _grpcServerCertPem == null) {
      _snack('TLS-Material noch nicht geladen.');
      return;
    }
    if (_discovery == null || _conn == null) {
      _snack('Services noch nicht initialisiert.');
      return;
    }

    setState(() => _busy = true);
    try {
      // Discovery ggf. auf neue URL umbauen
      final url = _effectiveConsulUrl();
      if (_discovery!.base.toString() != url) {
        _discovery?.dispose();
        _discovery = ConsulDiscovery(url, caPem: _consulCaPem!);
        _appendLog('Consul-URL gesetzt auf: $url');
      }

      final tag = _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim();
      _appendLog('Lade Services aus Consul …');

      // /v1/catalog/services (optional lokal per Tag filtern) :contentReference[oaicite:2]{index=2}
      final services = await _discovery!.listServices(tag: tag);
      if (!mounted) return;

      if (services.isEmpty) {
        _snack('Keine Services gefunden${tag != null ? " (Tag=$tag)" : ""}.');
        return;
      }

      final selectedService = await _showDlg<String>(
        SimpleDialog(
          title: const Text('Service auswählen'),
          children: [
            SizedBox(
              width: 420,
              height: 360,
              child: ListView.separated(
                itemCount: services.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => ListTile(
                  title: Text(services[i]),
                  onTap: () => Navigator.of(_navKey.currentContext!).pop(services[i]),
                ),
              ),
            ),
          ],
        ),
      );

      if (selectedService == null) return;

      _appendLog('Lade gesunde Instanzen für "$selectedService" …');

      // /v1/health/service/<name>?passing (nur "passing" Instanzen) :contentReference[oaicite:3]{index=3}
      final instances = await _discovery!.listHealthyInstances(
        serviceName: selectedService,
        tag: tag,
      );
      if (!mounted) return;

      if (instances.isEmpty) {
        _snack('Keine **gesunden** Instanzen für "$selectedService"${tag != null ? " (Tag=$tag)" : ""}.');
        return;
      }

      final inst = await _showDlg<ConsulInstance>(
        SimpleDialog(
          title: Text('Instanz auswählen – $selectedService'),
          children: [
            SizedBox(
              width: 520,
              height: 360,
              child: ListView.separated(
                itemCount: instances.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final it = instances[i];
                  final subtitle = it.id.isEmpty
                      ? (it.tags.isEmpty ? '—' : it.tags.join(', '))
                      : '${it.id}${it.tags.isEmpty ? '' : ' • ${it.tags.join(', ')}'}';
                  return ListTile(
                    title: Text('${it.host}:${it.port}'),
                    subtitle: Text(subtitle),
                    onTap: () => Navigator.of(_navKey.currentContext!).pop(it),
                  );
                },
              ),
            ),
          ],
        ),
      );

      if (inst == null) return;

      await _conn!.connect(instance: inst, selectedServiceName: selectedService);

      if (_conn!.kind == ServiceKind.camera) {
        await _ensureCameraLoaded();
      } else if (_conn!.kind == ServiceKind.polflash) {
        await _ensureFlashLoaded();
      }

      _appendLog('Verbunden ➜ ${inst.host}:${inst.port}'
          '${selectedService.isNotEmpty ? '  (Service: $selectedService)' : ''}'
          ' • Typ: ${_conn!.kind?.label ?? '-'}');
      setState(() {});
    } catch (e) {
      _appendLog('Fehler beim Verbinden: $e');
      _snack('Fehler: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gRPC Desktop Client',
      scaffoldMessengerKey: _messengerKey,
      navigatorKey: _navKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera/PolFlash gRPC Client (Consul)')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _consulCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Consul URL',
                        hintText: 'z. B. https://10.10.4.22:8501',
                      ),
                      onSubmitted: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _tagCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tag (optional, z. B. grpc)',
                      ),
                      onSubmitted: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: (_busy || _discovery == null) ? null : _browseAndConnect,
                    icon: const Icon(Icons.list),
                    label: const Text('Services durchsuchen'),
                  ),
                  const SizedBox(width: 12),
                  if (_busy)
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Service: ${_conn?.selectedServiceName ?? '—'}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Instanz: ${_conn?.instance == null ? '—' : '${_conn!.instance!.host}:${_conn!.instance!.port}'}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text('Profil:'),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<CaptureProfile>(
                    valueListenable: _profile,
                    builder: (_, p, __) => DropdownButton<CaptureProfile>(
                      value: p,
                      items: const [
                        DropdownMenuItem(value: CaptureProfile.low, child: Text('Low (720p / 4 Mbit)')),
                        DropdownMenuItem(value: CaptureProfile.fullHd, child: Text('FullHD (1080p / 12 Mbit)')),
                      ],
                      onChanged: (v) => v == null ? null : _profile.value = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_conn?.kind == ServiceKind.camera)
                Expanded(
                  flex: 3,
                  child: cam.CameraPage(conn: _conn!, log: _logBuffer.notifier, profile: _profile),
                )
              else if (_conn?.kind == ServiceKind.polflash)
                Expanded(
                  flex: 3,
                  child: fl.FlashPage(conn: _conn!, log: _logBuffer.notifier),
                )
              else
                const Expanded(flex: 3, child: SizedBox.shrink()),

              const SizedBox(height: 16),
              Expanded(flex: 2, child: LogPanel(text: _logBuffer.notifier)),
            ],
          ),
        ),
      ),
    );
  }
}
