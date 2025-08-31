using System.IO.Ports;
using System.Threading.Channels;

// Minimal VISCA controller for Sony FCB-EV7520A class cameras.
// Uses RS-232C VISCA protocol: 8 data bits, 1 start bit, 1 stop bit, no parity.
// Baud rate can be 9,600 to 115,200 bps (default is often 9,600).

public sealed class ViscaController : IDisposable
{
    private readonly SerialPort _port;
    private readonly byte _deviceAddress; // 1..7
    private readonly Channel<byte> _rx = Channel.CreateUnbounded<byte>();
    private readonly CancellationTokenSource _cts = new();
    private Task? _reader;

    public ViscaController(string portName, int baudRate = 9600, byte deviceAddress = 1)
    {
        if (deviceAddress is < 1 or > 7) throw new ArgumentOutOfRangeException(nameof(deviceAddress));
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

    private byte CmdHeader => (byte)(0x80 | _deviceAddress);
    private byte ReplyHeader => (byte)(0x80 | 0x08 | _deviceAddress);

    private async Task ReadLoopAsync()
    {
        var buf = new byte[256];
        while (!_cts.IsCancellationRequested)
        {
            try
            {
                var b = _port.ReadByte();
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
            if (b == 0xFF)
            {
                return list.ToArray();
            }
        }
    }

    private async Task<byte[]> SendAndAwaitAsync(byte[] body, int timeoutMs = 800, bool expectData = false)
    {
        // Alte Bytes verwerfen (verschobene Frames vermeiden)
        //DrainInput();
        DrainRx();
        // Paket senden (Header 8x ... FF)
        var pkt = new List<byte>(body.Length + 2) { (byte)(0x80 | _deviceAddress) };
        pkt.AddRange(body);
        pkt.Add(0xFF);
        _port.Write(pkt.ToArray(), 0, pkt.Count);

        // 1) Erstes Paket lesen (ACK, Completion oder Error)
        var first = await ReadPacketAsync(timeoutMs);

        // Error?
        if (first.Length >= 3 && (first[1] & 0xF0) == 0x60)
            throw new InvalidOperationException($"VISCA error 0x{first[2]:X2}: {Hex(first)}");

        // Direkt Completion erhalten?
        if ((first[0] & 0xF0) == 0x90 && (first[1] & 0xF0) == 0x50)
        {
            if (!expectData || first.Length > 3)
                return first; // keine Daten erwartet oder Daten sind schon dabei

            // Für Inquiries ggf. zweite Completion mit Daten abwarten
            var comp2 = await ReadPacketAsync(timeoutMs);
            if (comp2.Length >= 3 && (comp2[1] & 0xF0) == 0x60)
                throw new InvalidOperationException($"VISCA error 0x{comp2[2]:X2}: {Hex(comp2)}");
            if ((comp2[0] & 0xF0) == 0x90 && (comp2[1] & 0xF0) == 0x50)
                return comp2;

            // Fallback: wenn trotzdem nichts Sinnvolles, gib first zurück
            return first;
        }

        // ACK? -> Completion abwarten
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
                    // Wenn Daten erwartet, aber noch keine dabei, noch ein Paket versuchen
                    var r2 = await ReadPacketAsync(timeoutMs);
                    if (r2.Length >= 3 && (r2[1] & 0xF0) == 0x60)
                        throw new InvalidOperationException($"VISCA error 0x{r2[2]:X2}: {Hex(r2)}");
                    if ((r2[0] & 0xF0) == 0x90 && (r2[1] & 0xF0) == 0x50) return r2;
                    return r; // Fallback
                }
                // Sonst ignorieren (Notifications etc.)
            }
        }

        // Unbekanntes Paket – zur Diagnose zurückgeben
        return first;
    }



    private async Task InitializeNetworkAsync()
    {
        // Broadcast AddressSet: 88 30 01 FF
        _port.Write(new byte[] { 0x88, 0x30, 0x01, 0xFF }, 0, 4);
        await Task.Delay(50);
        DrainRx();
        // IF_Clear: 8x 01 00 01 FF
        await SendAndAwaitAsync(new byte[] { 0x01, 0x00, 0x01 }, 500, expectData: false);
        DrainRx();
    }

    // ---- Public high-level operations ----

    public async Task PowerAsync(bool on, int timeoutMs = 800)
    {
        // CAM_Power: On 8x 01 04 00 02 FF, Off 8x 01 04 00 03 FF
        var val = on ? (byte)0x02 : (byte)0x03;
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x00, val }, timeoutMs);
        CheckError(reply, "Power");
    }

    public async Task ZoomDirectAsync(ushort position, int timeoutMs = 800)
    {
        // CAM_Zoom Direct: 8x 01 04 47 0p 0q 0r 0s FF (pqrs = 16-bit BCD nybbles)
        // Position is 0x0000 .. 0x7AC0
        var nyb = ToNibbles(position);
        var body = new byte[] { 0x01, 0x04, 0x47, nyb[0], nyb[1], nyb[2], nyb[3] };
        var reply = await SendAndAwaitAsync(body, timeoutMs);
        CheckError(reply, "ZoomDirect");
    }

    public async Task ZoomVariableAsync(bool tele, byte speed, int timeoutMs = 800)
    {
        // CAM_Zoom Tele(Standard) 8x 01 04 07 02 FF
        // Variable: 8x 01 04 07 2p (Tele) or 3p (Wide), where p=0..7
        if (speed > 7) throw new ArgumentOutOfRangeException(nameof(speed));
        byte val = (byte)((tele ? 0x20 : 0x30) | speed);
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x07, val }, timeoutMs);
        CheckError(reply, "ZoomVariable");
    }

    public async Task ZoomStopAsync(int timeoutMs = 800)
    {
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x07, 0x00 }, timeoutMs);
        CheckError(reply, "ZoomStop");
    }

    public async Task SetFocusModeAsync(bool auto, int timeoutMs = 800)
    {
        // Auto Focus: 8x 01 04 38 02 FF, Manual Focus: 8x 01 04 38 03 FF
        var val = auto ? (byte)0x02 : (byte)0x03;
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x38, val }, timeoutMs);
        CheckError(reply, "SetFocusMode");
    }

    public async Task FocusDirectAsync(ushort position, int timeoutMs = 800)
    {
        // Focus Direct: 8x 01 04 48 0p 0q 0r 0s FF (pqrs = BCD)
        var nyb = ToNibbles(position);
        var reply = await SendAndAwaitAsync(new byte[] { 0x01, 0x04, 0x48, nyb[0], nyb[1], nyb[2], nyb[3] }, timeoutMs);
        CheckError(reply, "FocusDirect");
    }

    public async Task<bool> PowerInquiryAsync()
    {
        // 8x 09 04 00 FF -> y0 50 02 FF (On) oder y0 50 03 FF (Standby)
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x00 }, 800, expectData: true); // <-- statt direct _port.Write + einmal Read
        if (r.Length >= 4 && r[1] == 0x50)
            return r[2] == 0x02;
        throw new InvalidOperationException($"Unexpected power inquiry reply: {BitConverter.ToString(r)}");
    }

    public async Task<ushort> ZoomPosInquiryAsync()
    {
        // 8x 09 04 47 FF -> y0 50 0p 0q 0r 0s FF
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x47 }, 800, expectData: true); // <-- statt direct write+read
        if (r.Length >= 6 && r[1] == 0x50)
            return FromNibbles(r[2], r[3], r[4], r[5]);
        throw new InvalidOperationException($"Unexpected zoom inquiry reply: {BitConverter.ToString(r)}");
    }

    public async Task<ushort> FocusPosInquiryAsync()
    {
        // 8x 09 04 48 FF -> y0 50 0p 0q 0r 0s FF
        var r = await SendAndAwaitAsync(new byte[] { 0x09, 0x04, 0x48 }, 800, expectData: true); // <-- statt direct write+read
        if (r.Length >= 6 && r[1] == 0x50)
            return FromNibbles(r[2], r[3], r[4], r[5]);
        throw new InvalidOperationException($"Unexpected focus inquiry reply: {BitConverter.ToString(r)}");
    }


    private static void CheckError(byte[] reply, string label)
    {
        if (reply.Length >= 4 && reply[1] == 0x60)
        {
            var code = reply[2];
            throw new InvalidOperationException($"{label} VISCA error 0x{code:X2}: {BitConverter.ToString(reply)}");
        }
    }

    private static byte[] ToNibbles(ushort value)
    {
        // VISCA uses 4 nybble bytes (HH HL LH LL), each is 0x0i
        return new byte[] {
            (byte)((value >> 12) & 0x0F),
            (byte)((value >> 8)  & 0x0F),
            (byte)((value >> 4)  & 0x0F),
            (byte)((value >> 0)  & 0x0F)
        };
    }

    private static ushort FromNibbles(byte hh, byte hl, byte lh, byte ll)
    {
        return (ushort)((hh << 12) | (hl << 8) | (lh << 4) | ll);
    }

    private void DrainInput()
    {
        try
        {
            var buf = new byte[256];
            var start = Environment.TickCount64;
            while (_port.BytesToRead > 0 && Environment.TickCount64 - start < 20)
            {
                _port.Read(buf, 0, Math.Min(buf.Length, _port.BytesToRead));
            }
        }
        catch { /* ignore */ }
    }
    private void DrainRx()
    {
        // alles aus dem Channel ziehen, ohne zu blockieren
        while (_rx.Reader.TryRead(out _)) { }
    }

    private static string Hex(byte[] data) => BitConverter.ToString(data);

}
