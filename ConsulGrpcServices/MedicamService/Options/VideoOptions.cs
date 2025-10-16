namespace Medicam.Options;

/// <summary>
/// Platzhalter für spätere Video-Konfiguration (z. B. Gerätename),
/// aktuell nicht aus KV gebunden – für Prototyp nicht notwendig.
/// </summary>
public sealed class VideoOptions
{
    public string DefaultDeviceName { get; init; } = "XI100DUSB-SDI Video";
}
