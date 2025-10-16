namespace Medicam.Diagnostics;

/// <summary>
/// Einfache, lokale Fehlerinjektion für Tests (SerialTimeout).
/// Per /diag/faults?mode=SerialTimeout|None schaltbar (nur Loopback).
/// </summary>
public enum FaultMode { None, SerialTimeout }

public sealed class FaultState
{
    private readonly object _gate = new();
    private FaultMode _mode = FaultMode.None;

    public FaultMode Mode
    {
        get { lock (_gate) return _mode; }
        set { lock (_gate) _mode = value; }
    }
}
