// lib/shared/model/capture_profile.dart

/// Kompakte Beschreibung eines Capture-/Encode-Profils.
/// Wird für Live-Stream und TS-Save gleichermaßen verwendet.
class CaptureProfile {
  final int w, h, fps, bitrate;
  const CaptureProfile(this.w, this.h, this.fps, this.bitrate);

  static const low    = CaptureProfile(1280, 720, 30,  4 * 1000 * 1000);
  static const fullHd = CaptureProfile(1920, 1080, 30, 12 * 1000 * 1000);
}
