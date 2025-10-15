using System.IO.Ports;
using System.Threading.Channels;

/// <summary>
/// VISCA-Controller für Sony-kompatible Kameras (z. B. FCB-Serie).
/// Implementiert Power, Zoom (Direktposition) und Statusabfragen.
/// Thread-safe (I/O serialisiert), Timeout/Retry, Port-Reopen für Robustheit.
/// </summary>
public sealed class ViscaController : IDisposable
{
    private readonly SerialPort _port;
    private readonly byte _deviceAddress;            // 1..7
    private readonly Channel<byte> _rx = Channel.CreateUnbounded<byte>();
    private readonly CancellationTokenSource _cts = new();
    private Task? _reader;

    // Serialisiert alle I/O-Zyklen (SerialPort ist nicht thread-safe)
    private readonly SemaphoreSlim _io = new(1, 1);

    private readonly string _portName;
    private readonly int _baudRate;

    public ViscaController(string portName, int baudRate = 9600, byte deviceAddress = 1)
    {
        if (deviceAddress < 1 || deviceAddress > 7)
            throw new ArgumentOutOfRangeException(nameof(deviceAddress));

        _deviceAddress = deviceAddress;
        _portName = portName;
        _baudRate = baudRate;

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
                int b = _port.ReadByte();
                await _rx.Writer.WriteAsync((byte)b, _cts.Token);
            }
            catch
            {
                await Task.Delay(5, _cts.Token);
            }
        }
    }

    private async Task<byte[]> ReadPacketAsync(int timeoutMs = 500)
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

    /// <summary>
    /// Sendet ein VISCA-Kommando; wartet auf ACK/Completion (+optional Daten).
    /// Enthält Locking, leichte Retries, und Reopen bei IO-Ausfall.
    /// </summary>
    private async Task<byte[]> SendAndAwaitAsync(byte[] body, int timeoutMs = 800, bool expectData = false)
    {
        await _io.WaitAsync(_cts.Token);
        try
        {
            for (int attempt = 1; attempt <= 2; attempt++)
            {
                try
                {
                    DrainRx(); // alte Bytes verwerfen

                    var pkt = new List<byte>(body.Length + 2) { (byte)(0x80 | _deviceAddress) };
                    pkt.AddRange(body);
                    pkt.Add(0xFF);
                    _port.Write(pkt.ToArray(), 0, pkt.Count);

                    var first = await ReadPacketAsync(timeoutMs);

                    // VISCA Error?
                    if (first.Length >= 3 && (first[1] & 0xF0) == 0x60)
                        throw new InvalidOperationException($"VISCA error 0x{first[2]:X2}: {Hex(first)}");

                    // Direct Completion (ggf. inkl. Daten)
                    if ((first[0] & 0xF0) == 0x90 && (first[1] & 0xF0) == 0x50)
                    {
                        if (!expectData || first.Length > 3) return first;

                        var comp2 = await ReadPacketAsync(timeoutMs);
                        if (comp2.Length >= 3 && (comp2[1] & 0xF0) == 0x60)
                            throw new InvalidOperationException($"VISCA error 0x{comp2[2]:X2}: {Hex(comp2)}");
                        if ((comp2[0] & 0xF0) == 0x90 && (comp2[1] & 0xF0) == 0x50)
                            return comp2;

                        return first; // Fallback
                    }

                    // ACK → Completion abwarten
                    if ((first[0] & 0xF0) == 0x90 && (first[1] & 0xF0) == 0x40)
                    {
                        while (true)
                        {
                            var r = await ReadPacketAsync(timeoutMs);
                            if (r.Length >= 3 && (r[1] & 0xF0) == 0x60)
                                throw new InvalidOperationException($"VISCA error 0x{r[2]:X2}: {Hex(r)}");
                            if ((r[0] & 0xF0) == 0x90 && (r[1] & 0xF0) == 0x50)
                            {
                                if (!expectData || r.Length > 3) return r;

                                var r2 = await ReadPacketAsync(timeoutMs);
                                if (r2.Length >= 3 && (r2[1] & 0xF0) == 0x60)
                                    throw new InvalidOperationException($"VISCA error 0x{r2[2]:X2}: {Hex(r2)}");
                                if ((r2[0] & 0xF0) == 0x90 && (r2[1] & 0xF0) == 0x50) return r2;
                                return r; // Fallback
                            }
                        }
                    }

                    // ansonsten: unbekanntes Paket zur Diagnose
                    return first;
                }
                catch (OperationCanceledException) when (attempt < 2)
                {
                    await Task.Delay(100, _cts.Token);
                    continue;
                }
                catch (TimeoutException) when (attempt < 2)
                {
                    await Task.Delay(100, _cts.Token);
                    continue;
                }
                catch (IOException)
                {
                    if (attempt < 2)
                    {
                        ReopenPort();
                        await Task.Delay(150, _cts.Token);
                        continue;
                    }
                    throw;
                }
            }

            throw new TimeoutException("VISCA timeout after retries");
        }
        finally
        {
            _io.Release();
        }
    }

    private async Task InitializeNetworkAsync()
    {
        // Broadcast AddressSet
        _port.Write(new byte[] { 0x88, 0x30, 0x01, 0xFF }, 0, 4);
        await Task.Delay(50);
        DrainRx();

        // IF_Clear
        await SendAndAwaitAsync(new byte[] { 0x01, 0x00, 0x01 }, 500, expectData: false);
        DrainRx();
    }

    // ---- Öffentliche Operationen ----

    public async Task PowerAsync(bool on, int timeoutMs = 800)
    {
        var val = on ? (byte)0x02 : (byte)0x03;
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x00, val }, timeoutMs);
        CheckError(reply, "Power");
    }

    public async Task ZoomDirectAsync(ushort position, int timeoutMs = 800)
    {
        var nyb = ToNibbles(position); // 0x0000..0x7AC0
        var body = new byte[] { 0x01, 0x04, 0x47, nyb[0], nyb[1], nyb[2], nyb[3] };
        var reply = await SendAndAwaitAsync(body, timeoutMs);
        CheckError(reply, "ZoomDirect");
    }

    public async Task<bool> PowerInquiryAsync()
    {
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x00 }, 800, expectData: true);
        if (r.Length >= 4 && r[1] == 0x50) return r[2] == 0x02;
        throw new InvalidOperationException($"Unexpected power inquiry reply: {BitConverter.ToString(r)}");
    }

    public async Task<ushort> ZoomPosInquiryAsync()
    {
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x47 }, 800, expectData: true);
        if (r.Length >= 6 && r[1] == 0x50) return FromNibbles(r[2], r[3], r[4], r[5]);
        throw new InvalidOperationException($"Unexpected zoom inquiry reply: {BitConverter.ToString(r)}");
    }

    // ---- Utils ----

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

    private void DrainRx()
    {
        while (_rx.Reader.TryRead(out _)) { }
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

    private static string Hex(byte[] data) => BitConverter.ToString(data);
}
