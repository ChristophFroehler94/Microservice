namespace Camera.Grpc.Service
{
    /// <summary>
    /// Strongly-typed Option für den Default-DirectShow-Gerätenamen.
    /// Kein Binding aus KV – rein interner Default für den Prototyp.
    /// </summary>
    public sealed record VideoOptions
    {
        public string DefaultDeviceName { get; init; } = "XI100DUSB-SDI Video";
    }
}
