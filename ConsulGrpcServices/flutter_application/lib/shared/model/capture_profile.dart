/// Kompakte Beschreibung eines Capture-/Encode-Profils.
/// Wird für Live-Stream und TS-Save gleichermaßen verwendet.
class CaptureProfile {
  final String deviceId;
  final int w, h, fps, bitrate;
  const CaptureProfile(this.deviceId, this.w, this.h, this.fps, this.bitrate);

  static const low = CaptureProfile('USB Capture SDI', 1280, 720, 30, 4 * 1000 * 1000);
  static const fullHd = CaptureProfile('USB Capture SDI', 1920, 1080, 30, 12 * 1000 * 1000);
}