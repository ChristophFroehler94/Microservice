import 'package:flutter/material.dart';

import '../../core/connection/connection_service.dart';
import '../../src/generated/flashcontrol.pbgrpc.dart' as pol;
import '../../src/generated/google/protobuf/empty.pb.dart' as wkt;

/// Seite für PolFlash‑Steuerung mit den wichtigsten RPC‑Aufrufen.
class FlashPage extends StatelessWidget {
  const FlashPage({super.key, required this.conn, required this.log});

  final ConnectionService conn;
  final ValueNotifier<String> log;

  pol.FlashControlClient? get _flash => conn.flash;

  void _appendLog(String msg) => log.value = '${log.value}\n$msg';

  Future<void> _charge() async {
    if (_flash == null) return;
    try {
      final res = await _flash!.charge(wkt.Empty());
      _appendLog('Charge: ok=${res.success} msg=${res.message}');
    } catch (e) {
      _appendLog('Charge‑Fehler: $e');
    }
  }

  Future<void> _discharge() async {
    if (_flash == null) return;
    try {
      final res = await _flash!.discharge(wkt.Empty());
      _appendLog('Discharge: ok=${res.success} msg=${res.message}');
    } catch (e) {
      _appendLog('Discharge‑Fehler: $e');
    }
  }

  Future<void> _trigger() async {
    if (_flash == null) return;
    try {
      final res = await _flash!.trigger(wkt.Empty());
      _appendLog('Trigger: ok=${res.success} msg=${res.message}');
    } catch (e) {
      _appendLog('Trigger‑Fehler: $e');
    }
  }

  Future<void> _getState() async {
    if (_flash == null) return;
    try {
      final st = await _flash!.getFlashState(wkt.Empty());
      _appendLog('FlashState: state=${st.state}');
    } catch (e) {
      _appendLog('GetFlashState‑Fehler: $e');
    }
  }

  Future<void> _getCount() async {
    if (_flash == null) return;
    try {
      final r = await _flash!.getFlashCount(wkt.Empty());
      _appendLog('FlashCount: ${r.count}');
    } catch (e) {
      _appendLog('GetFlashCount‑Fehler: $e');
    }
  }

  Future<void> _getEnergy() async {
    if (_flash == null) return;
    try {
      final r = await _flash!.getFlashEnergy(wkt.Empty());
      _appendLog('Energy: right=${r.percentageRight.toStringAsFixed(1)}%  left=${r.percentageLeft.toStringAsFixed(1)}%');
    } catch (e) {
      _appendLog('GetEnergy‑Fehler: $e');
    }
  }

  Future<void> _getPolarization() async {
    if (_flash == null) return;
    try {
      final r = await _flash!.getPolarizationMode(wkt.Empty());
      _appendLog('Polarization: right=${r.rightMode} left=${r.leftMode}');
    } catch (e) {
      _appendLog('GetPolarization‑Fehler: $e');
    }
  }

  Future<void> _setEnergy() async {
    if (_flash == null) return;
    try {
      final r = await _flash!.setFlashEnergy(
        pol.SetFlashEnergyRequest()
          ..percentageRight = 50
          ..percentageLeft = 50,
      );
      _appendLog('SetEnergy: ok=${r.success} msg=${r.message}');
    } catch (e) {
      _appendLog('SetEnergy‑Fehler: $e');
    }
  }

  Future<void> _setPol() async {
    if (_flash == null) return;
    try {
      final r = await _flash!.setPolarization(
        pol.SetPolarizationRequest()
          ..rightMode = pol.SetPolarizationRequest_PolarizationMode.Polarized
          ..leftMode = pol.SetPolarizationRequest_PolarizationMode.Unpolarized,
      );
      _appendLog('SetPolarization: ok=${r.success} msg=${r.message}');
    } catch (e) {
      _appendLog('SetPolarization‑Fehler: $e');
    }
  }

  Future<void> _laser(bool on) async {
    if (_flash == null) return;
    try {
      final r = await _flash!.setLaser(pol.LaserRequest()..isActive = on);
      _appendLog('Laser(${on ? 'ON' : 'OFF'}): ok=${r.success} msg=${r.message}');
    } catch (e) {
      _appendLog('Laser‑Fehler: $e');
    }
  }

  Future<void> _getVersions() async {
    if (_flash == null) return;
    try {
      final sw = await _flash!.getSoftwareVersion(wkt.Empty());
      final hw = await _flash!.getHardwareVersion(wkt.Empty());
      _appendLog('Versionen: SW ${sw.major}.${sw.minor}  •  HW ${hw.major}.${hw.minor}');
    } catch (e) {
      _appendLog('Version‑Fehler: $e');
    }
  }

  Future<void> _getStateMachine() async {
    if (_flash == null) return;
    try {
      final r = await _flash!.getStateMachine(wkt.Empty());
      _appendLog('StateMachine: state=${r.state}');
    } catch (e) {
      _appendLog('GetStateMachine‑Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(onPressed: _flash != null ? _charge : null, child: const Text('Charge')),
          ElevatedButton(onPressed: _flash != null ? _discharge : null, child: const Text('Discharge')),
          ElevatedButton(onPressed: _flash != null ? _trigger : null, child: const Text('Trigger')),
          ElevatedButton(onPressed: _flash != null ? _getState : null, child: const Text('Get State')),
          ElevatedButton(onPressed: _flash != null ? _getCount : null, child: const Text('Get Count')),
          ElevatedButton(onPressed: _flash != null ? _getEnergy : null, child: const Text('Get Energy')),
          ElevatedButton(onPressed: _flash != null ? _getPolarization : null, child: const Text('Get Polarization')),
          ElevatedButton(onPressed: _flash != null ? _setEnergy : null, child: const Text('Set Energy 50/50')),
          ElevatedButton(onPressed: _flash != null ? _setPol : null, child: const Text('Pol: R=Pol L=Unpol')),
          ElevatedButton(onPressed: _flash != null ? () => _laser(true) : null, child: const Text('Laser ON')),
          ElevatedButton(onPressed: _flash != null ? () => _laser(false) : null, child: const Text('Laser OFF')),
          ElevatedButton(onPressed: _flash != null ? _getVersions : null, child: const Text('Get Versions')),
          ElevatedButton(onPressed: _flash != null ? _getStateMachine : null, child: const Text('Get StateMachine')),
        ],
      ),
    );
  }
}