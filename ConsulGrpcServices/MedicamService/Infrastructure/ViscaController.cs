using Medicam.Diagnostics;
using System.Diagnostics;
using System.IO.Ports;
using System.Threading.Channels;

namespace Medicam.Infrastructure;

/// <summary>
/// VISCA-Controller (Sony-kompatibel): Power, ZoomDirect, Inquiries.
/// - Serialisiert I/O, Retries/Backoff, Port-Reopen bei IO-Ausfall.
/// - Metriken: Dauer je Kommando, Retry- und Port-Reopen-Zähler.
/// - Optional: Fehlerinjektion "SerialTimeout".
/// </summary>
public sealed class ViscaController : IDisposable
{
    private readonly SerialPort _port;
    private readonly byte _deviceAddress;
    private readonly Channel<byte> _rx = Channel.CreateUnbounded<byte>();
    private readonly CancellationTokenSource _cts = new();
    private Task? _reader;
    private readonly SemaphoreSlim _io = new(1, 1);
    private readonly string _portName;
    private readonly int _baudRate;
    private readonly FaultState _faults;

    public ViscaController(string portName, int baudRate, byte deviceAddress, FaultState faults)
    {
        if (deviceAddress < 1 || deviceAddress > 7) throw new ArgumentOutOfRangeException(nameof(deviceAddress));
        _faults = faults;

        _portName = portName;
        _baudRate = baudRate;
        _deviceAddress = deviceAddress;

        _port = new SerialPort(portName, baudRate, Parity.None, 8, StopBits.One)
        {
            Handshake = Handshake.None,
            ReadTimeout = 1000,
            WriteTimeout = 1000
        };

        _port.Open();
        _reader = Task.Run(ReadLoopAsync);
        InitializeNetworkAsync().GetAwaiter().GetResult();
    }

    public void Dispose()
    {
        try { _cts.Cancel(); } catch { }
        try { _reader?.Wait(500); } catch { }
        try { if (_port.IsOpen) _port.Close(); } catch { }
        _port.Dispose();
    }

    private async Task ReadLoopAsync()
    {
        while (!_cts.IsCancellationRequested)
        {
            try
            {
                var b = _port.ReadByte();
                await _rx.Writer.WriteAsync((byte)b, _cts.Token);
            }
            catch { await Task.Delay(5, _cts.Token); }
        }
    }

    private void DrainRx() { while (_rx.Reader.TryRead(out _)) { } }

    private async Task<byte[]> ReadPacketAsync(int timeoutMs)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token);
        cts.CancelAfter(timeoutMs);
        var list = new List<byte>(16);
        while (true)
        {
            var b = await _rx.Reader.ReadAsync(cts.Token);
            list.Add(b);
            if (b == 0xFF) return list.ToArray();
        }
    }

    private static string Hex(byte[] data) => BitConverter.ToString(data);

    private async Task InitializeNetworkAsync()
    {
        // Broadcast AddressSet
        _port.Write(new byte[] { 0x88, 0x30, 0x01, 0xFF }, 0, 4);
        await Task.Delay(50);
        DrainRx();

        // IF_Clear
        await SendAndAwaitAsync(new byte[] { 0x01, 0x00, 0x01 }, 500, expectData: false, label: "IF_Clear");
        DrainRx();
    }

    private async Task<byte[]> SendAndAwaitAsync(byte[] body, int timeoutMs, bool expectData, string label)
    {
        await _io.WaitAsync(_cts.Token);
        try
        {
            int attempt = 0;
            var sw = Stopwatch.StartNew();

            while (true)
            {
                attempt++;
                try
                {
                    if (_faults.Mode == FaultMode.SerialTimeout)
                    {
                        // künstliche Verzögerung → provoziert Timeout
                        await Task.Delay(timeoutMs + 100);
                    }

                    DrainRx();
                    var pkt = new List<byte>(body.Length + 2) { (byte)(0x80 | _deviceAddress) };
                    pkt.AddRange(body);
                    pkt.Add(0xFF);
                    _port.Write(pkt.ToArray(), 0, pkt.Count);

                    var first = await ReadPacketAsync(timeoutMs);

                    // Fehler?
                    if (first.Length >= 3 && (first[1] & 0xF0) == 0x60)
                        throw new InvalidOperationException($"{label} VISCA error 0x{first[2]:X2}: {Hex(first)}");

                    // Completion (ggf. Daten)
                    if ((first[0] & 0xF0) == 0x90 && (first[1] & 0xF0) == 0x50)
                    {
                        Medicam.Diagnostics.Metrics.ViscaCommandDurationMs.Record(sw.Elapsed.TotalMilliseconds,
                            KeyValuePair.Create<string, object?>("cmd", label));
                        return first;
                    }

                    // ACK → Completion erwarten
                    if ((first[0] & 0xF0) == 0x90 && (first[1] & 0xF0) == 0x40)
                    {
                        while (true)
                        {
                            var r = await ReadPacketAsync(timeoutMs);
                            if (r.Length >= 3 && (r[1] & 0xF0) == 0x60)
                                throw new InvalidOperationException($"{label} VISCA error 0x{r[2]:X2}: {Hex(r)}");
                            if ((r[0] & 0xF0) == 0x90 && (r[1] & 0xF0) == 0x50)
                            {
                                Medicam.Diagnostics.Metrics.ViscaCommandDurationMs.Record(sw.Elapsed.TotalMilliseconds,
                                    KeyValuePair.Create<string, object?>("cmd", label));
                                return r;
                            }
                        }
                    }

                    // Unerwartet → trotzdem Dauer protokollieren
                    Medicam.Diagnostics.Metrics.ViscaCommandDurationMs.Record(sw.Elapsed.TotalMilliseconds,
                        KeyValuePair.Create<string, object?>("cmd", label));
                    return first;
                }
                catch (TimeoutException) when (attempt <= 2)
                {
                    Medicam.Diagnostics.Metrics.ViscaRetryTotal.Add(1, KeyValuePair.Create<string, object?>("command", label));
                    await Task.Delay(100, _cts.Token);
                    continue;
                }
                catch (OperationCanceledException) when (attempt <= 2)
                {
                    Medicam.Diagnostics.Metrics.ViscaRetryTotal.Add(1, KeyValuePair.Create<string, object?>("command", label));
                    await Task.Delay(100, _cts.Token);
                    continue;
                }
                catch (IOException) when (attempt <= 2)
                {
                    ReopenPort();
                    Medicam.Diagnostics.Metrics.ViscaPortReopenTotal.Add(1);
                    await Task.Delay(150, _cts.Token);
                    continue;
                }
            }
        }
        finally { _io.Release(); }
    }

    private void ReopenPort()
    {
        try { if (_port.IsOpen) _port.Close(); } catch { }
        try
        {
            _port.PortName = _portName;
            _port.BaudRate = _baudRate;
            _port.Open();
        }
        catch { /* nächster Versuch bei nächstem Aufruf */ }
    }

    public async Task PowerAsync(bool on, int timeoutMs = 800)
    {
        var val = on ? (byte)0x02 : (byte)0x03;
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x00, val }, timeoutMs, false, "Power");
        CheckError(reply, "Power");
    }

    public async Task ZoomDirectAsync(ushort position, int timeoutMs = 800)
    {
        var nyb = ToNibbles(position);
        var body = new byte[] { 0x01, 0x04, 0x47, nyb[0], nyb[1], nyb[2], nyb[3] };
        var reply = await SendAndAwaitAsync(body, timeoutMs, false, "ZoomDirect");
        CheckError(reply, "ZoomDirect");
    }

    public async Task<bool> PowerInquiryAsync()
    {
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x00 }, 800, true, "PowerInquiry");
        if (r.Length >= 4 && r[1] == 0x50) return r[2] == 0x02;
        throw new InvalidOperationException($"Unexpected power inquiry reply: {Hex(r)}");
    }

    public async Task<ushort> ZoomPosInquiryAsync()
    {
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x47 }, 800, true, "ZoomPosInquiry");
        if (r.Length >= 6 && r[1] == 0x50) return FromNibbles(r[2], r[3], r[4], r[5]);
        throw new InvalidOperationException($"Unexpected zoom inquiry reply: {Hex(r)}");
    }

    private static void CheckError(byte[] reply, string label)
    {
        if (reply.Length >= 4 && reply[1] == 0x60)
            throw new InvalidOperationException($"{label} VISCA error 0x{reply[2]:X2}: {BitConverter.ToString(reply)}");
    }

    private static byte[] ToNibbles(ushort value) => new byte[]
    {
        (byte)((value >> 12) & 0x0F),
        (byte)((value >> 8)  & 0x0F),
        (byte)((value >> 4)  & 0x0F),
        (byte)( value        & 0x0F)
    };

    private static ushort FromNibbles(byte hh, byte hl, byte lh, byte ll)
        => (ushort)((hh << 12) | (hl << 8) | (lh << 4) | ll);
}
