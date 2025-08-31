using FFMpegCore;
using FFMpegCore.Pipes;
using Microsoft.Extensions.Logging.Abstractions;
using System.IO.Pipes;
using System.Runtime.CompilerServices;


public class FfmpegCoreVideoStream
{
    private readonly string _pipeName = Guid.NewGuid().ToString();
    private readonly ILogger<FfmpegCoreVideoStream> _log;

    //public FfmpegCoreVideoStream(ILogger<FfmpegCoreVideoStream>? log = null)
    //{
    //    _log = log ?? NullLogger<FfmpegCoreVideoStream>.Instance;  // <-- Fallback
    //}

    //public async IAsyncEnumerable<byte[]> StreamTsAsync(
    //    string deviceName,
    //    int width,
    //    int height,
    //    int fps,
    //    int bitrate,
    //    [EnumeratorCancellation] CancellationToken cancellation)
    //{
    //    // 1) Named-Pipe-Server (schreibt) 
    //    await using var pipeServer = new NamedPipeServerStream(
    //        _pipeName, PipeDirection.Out, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous);

    //    // 2) Named-Pipe-Client (liest) 
    //    var pipeClient = new NamedPipeClientStream(".", _pipeName, PipeDirection.In, PipeOptions.Asynchronous);

    //    // Beginne den Verbindungsaufbau parallel:
    //    var serverWait = pipeServer.WaitForConnectionAsync(cancellation);
    //    var clientConnect = pipeClient.ConnectAsync(cancellation);

    //    await Task.WhenAll(serverWait, clientConnect);

    //    // 3) Wickele den Server-Stream in einen FFmpegCore-Sink
    //    var sink = new StreamPipeSink(pipeServer);

    //    var gop = Math.Max(1, fps * 1);          // ~2 Sekunden GOP (kannst auch 1s wählen: fps*1)
    //    var vbv = Math.Max(200_000, bitrate / 4); // ~0.5s VBV -> kleinere Puffer = geringere Latenz

    //    _log.LogInformation("FFmpeg START dev='{Dev}' {W}x{H}@{Fps} bitrate={Bitrate}",
    //     deviceName, width, height, fps, bitrate);

    //    // 4) Starte FFmpeg, das in den Named-Pipe-Server schreibt
    //    var ffmpegTask = FFMpegArguments
    //        //.FromDeviceInput($"\"video={deviceName}\"", opts => opts
    //        //    .WithCustomArgument("-fflags nobuffer")
    //        //    .WithCustomArgument("-f dshow")
    //        //    .WithCustomArgument("-rtbufsize 16M")
    //        //    .WithCustomArgument("-pixel_format yuyv422")
    //        //    .WithCustomArgument($"-framerate {fps}")
    //        //    .WithCustomArgument($"-video_size {width}x{height}")
    //        //    .WithCustomArgument("-loglevel info")
    //        //    .WithCustomArgument("-stats"))
    //        //.OutputToPipe(sink, opts => opts
    //        //    .WithCustomArgument("-c:v libx264")
    //        //    .WithCustomArgument("-preset ultrafast")
    //        //    .WithCustomArgument("-tune zerolatency")
    //        //    .WithCustomArgument("-bf 0")                 // keine B-Frames
    //        //    .WithCustomArgument($"-g {gop}")             // GOP-Länge
    //        //    .WithCustomArgument("-sc_threshold 0")       // keine spontanen IDRs
    //        //    .WithCustomArgument($"-b:v {bitrate}")
    //        //    .WithCustomArgument($"-maxrate {bitrate}")
    //        //    .WithCustomArgument($"-bufsize {vbv}")       // kleiner VBV-Puffer
    //        //    .WithCustomArgument("-pix_fmt yuv420p")
    //        //    // TS-Muxer „scharf schalten“
    //        //    .WithCustomArgument("-muxpreload 0")
    //        //    .WithCustomArgument("-muxdelay 0")           // entfernt ~1.4 s Default-Offset im TS
    //        //    .WithCustomArgument("-flush_packets 1")      // Pakete sofort raus
    //        //    .WithCustomArgument("-mpegts_flags +resend_headers+initial_discontinuity")
    //        //    .WithCustomArgument("-f mpegts"))
    //        .FromDeviceInput($"\"video={deviceName}\"", opts => opts
    //          .WithCustomArgument("-f dshow")
    //          .WithCustomArgument("-pixel_format yuyv422")
    //          .WithCustomArgument($"-framerate {fps}")
    //          .WithCustomArgument($"-video_size {width}x{height}")
    //          .WithCustomArgument("-rtbufsize 16M")
    //          .WithCustomArgument("-fflags +nobuffer")
    //          .WithCustomArgument("-use_wallclock_as_timestamps 1") // real-time PTS
    //        )
    //        .OutputToPipe(sink, opts => opts
    //            .WithCustomArgument("-c:v libx264")
    //            .WithCustomArgument("-preset ultrafast")
    //            .WithCustomArgument("-tune zerolatency")
    //            .WithCustomArgument("-bf 0")                     // no B-frames
    //            .WithCustomArgument($"-g {fps}")                 // fixed GOP = 1 second
    //            .WithCustomArgument("-x264-params scenecut=0:min-keyint=" + fps) // no scene cuts
    //            .WithCustomArgument($"-b:v {bitrate}")           // CBR-style
    //            .WithCustomArgument($"-maxrate {bitrate}")
    //            .WithCustomArgument($"-bufsize {Math.Max(100_000, bitrate / 4)}")  // ~0.25–0.5s VBV
    //            .WithCustomArgument("-pix_fmt yuv420p")

    //            // ↓↓↓ Muxer & IO latency killers
    //            .WithCustomArgument("-f mpegts")
    //            .WithCustomArgument("-fflags +nobuffer")
    //            .WithCustomArgument("-avioflags direct")
    //            .WithCustomArgument("-flush_packets 1")
    //            .WithCustomArgument("-muxpreload 0")
    //            .WithCustomArgument("-muxdelay 0")
    //            .WithCustomArgument("-mpegts_flags +resend_headers+initial_discontinuity")
    //        )
    //        .CancellableThrough(cancellation)
    //        .ProcessAsynchronously();

    //    // Optional: Fehler von ffmpeg separat loggen, ohne catch im Iterator
    //    _ = ffmpegTask.ContinueWith(t =>
    //        _log.LogError(t.Exception!, "FFmpeg faulted for '{Dev}'", deviceName),
    //        TaskContinuationOptions.OnlyOnFaulted);

    //    var buffer = new byte[8 * 1024];

    //    try
    //    {
    //        while (!cancellation.IsCancellationRequested)
    //        {
    //            int read = await pipeClient.ReadAsync(buffer, 0, buffer.Length, cancellation);
    //            if (read <= 0) break;
    //            yield return buffer.AsSpan(0, read).ToArray();
    //        }

    //        // ffmpeg sauber beenden (Ausnahmen propagieren nach außen)
    //        await ffmpegTask;
    //    }
    //    finally
    //    {
    //        // Cleanup oder Info-Log ist ok (kein yield hier!)
    //        _log.LogInformation("FFmpeg stream finished for '{Dev}'", deviceName);
    //    }
    //}

    public FfmpegCoreVideoStream(ILogger<FfmpegCoreVideoStream>? log = null)
    {
        _log = log ?? NullLogger<FfmpegCoreVideoStream>.Instance;
    }

    /// <summary>
    /// Liefert einen Low-Latency-MPEG-TS-Bytestrom (H.264) als Chunks.
    /// Rückgabewerte sind <see cref="ReadOnlyMemory{byte}"/>-Slices auf einen Puffer,
    /// der pro Iteration wiederverwendet wird (Zero-Copy-freundlich für gRPC).
    /// </summary>
    public async IAsyncEnumerable<ReadOnlyMemory<byte>> StreamTsAsync(
        string deviceName,
        int width,
        int height,
        int fps,
        int bitrate,
        [EnumeratorCancellation] CancellationToken cancellation)
    {
        // 1) Named-Pipe-Server (FFmpeg schreibt hinein)
        await using var pipeServer = new NamedPipeServerStream(
            _pipeName,
            PipeDirection.Out,
            1,
            PipeTransmissionMode.Byte,
            PipeOptions.Asynchronous);

        // 2) Named-Pipe-Client (wir lesen heraus)
        using var pipeClient = new NamedPipeClientStream(".", _pipeName, PipeDirection.In, PipeOptions.Asynchronous);

        // Beide Enden verbinden (gleicher Prozess)
        var serverWait = pipeServer.WaitForConnectionAsync(cancellation);
        var clientConnect = pipeClient.ConnectAsync(cancellation);
        await Task.WhenAll(serverWait, clientConnect);

        // 3) FFmpeg-Sink
        var sink = new StreamPipeSink(pipeServer);

        //var vbv = Math.Max(100_000, bitrate / 4);   // ~0,25–0,5 s VBV für geringe Latenz

        _log.LogInformation("FFmpeg START dev='{Dev}' {W}x{H}@{Fps} bitrate={Bitrate}",
            deviceName, width, height, fps, bitrate);
        // in FfmpegCoreVideoStream.OutputToPipe(...) – x264-Parameter ergänzen
        var vbv = Math.Max(250_000, bitrate / 2); // etwas größerer VBV (~0,5 s) glättet Spitzen

        var x264Params = string.Join(":",
            $"scenecut=0",                // keine spontanen IDRs
            $"rc-lookahead=0",            // für niedrige Latenz
            $"keyint={fps}",              // 1s "Key-Intervall" (bei intra-refresh kein harter IDR-Burst)
            $"min-keyint={fps}",
            $"intra-refresh=1",           // verteilt I-Daten -> weniger Burst
            $"nal-hrd=cbr"               // hard-CBR (mit Filler-Bytes)
        );

        var ffmpegTask =
        FFMpegArguments
          .FromDeviceInput($"\"video={deviceName}\"", opts => opts
              .WithCustomArgument("-f dshow")
              .WithCustomArgument("-pixel_format yuyv422")
              .WithCustomArgument($"-framerate {fps}")
              .WithCustomArgument($"-video_size {width}x{height}")
              .WithCustomArgument("-rtbufsize 16M")
              .WithCustomArgument("-fflags +nobuffer")
              .WithCustomArgument("-use_wallclock_as_timestamps 1"))
          .OutputToPipe(sink, opts => opts
              .WithCustomArgument("-c:v libx264")
              .WithCustomArgument("-preset superfast")
              .WithCustomArgument("-tune zerolatency")
              .WithCustomArgument("-bf 0")
              .WithCustomArgument($"-g {fps}") // 1 Sek.
              .WithCustomArgument($"-x264-params {x264Params}")
              .WithCustomArgument($"-b:v {bitrate}")
              .WithCustomArgument($"-maxrate {bitrate}")
              .WithCustomArgument($"-bufsize {vbv}")
              .WithCustomArgument("-pix_fmt yuv420p")
              // TS-Muxer: latenzarm
              .WithCustomArgument("-f mpegts")
              .WithCustomArgument("-fflags +nobuffer")
              .WithCustomArgument("-avioflags direct")
              .WithCustomArgument("-flush_packets 1")
              .WithCustomArgument("-muxpreload 0")
              .WithCustomArgument("-muxdelay 0")
              .WithCustomArgument("-mpegts_flags +resend_headers+initial_discontinuity"))
          .CancellableThrough(cancellation)
          .ProcessAsynchronously();

        //// 4) FFmpeg: Low-Latency Capture + Encode + TS-Mux
        //var ffmpegTask =
        //    FFMpegArguments
        //        .FromDeviceInput($"\"video={deviceName}\"", opts => opts
        //            .WithCustomArgument("-f dshow")
        //            .WithCustomArgument("-pixel_format yuyv422")
        //            .WithCustomArgument($"-framerate {fps}")
        //            .WithCustomArgument($"-video_size {width}x{height}")
        //            .WithCustomArgument("-rtbufsize 16M")
        //            .WithCustomArgument("-fflags +nobuffer")                 // weniger Eingangs-Puffer
        //            .WithCustomArgument("-use_wallclock_as_timestamps 1")     // Realtime-PTS
        //        )
        //        .OutputToPipe(sink, opts => opts
        //            .WithCustomArgument("-c:v libx264")
        //            .WithCustomArgument("-preset ultrafast")
        //            .WithCustomArgument("-tune zerolatency")
        //            .WithCustomArgument("-bf 0")                              // keine B-Frames
        //            .WithCustomArgument($"-g {fps}")                          // GOP = 1 s
        //            .WithCustomArgument($"-x264-params scenecut=0:min-keyint={fps}")
        //            .WithCustomArgument($"-b:v {bitrate}")                    // CBR-artig
        //            .WithCustomArgument($"-maxrate {bitrate}")
        //            .WithCustomArgument($"-bufsize {vbv}")                    // kleiner VBV
        //            .WithCustomArgument("-pix_fmt yuv420p")

        //            // TS-Muxer & IO: aggressiv entpuffern
        //            .WithCustomArgument("-f mpegts")
        //            .WithCustomArgument("-fflags +nobuffer")
        //            .WithCustomArgument("-avioflags direct")
        //            .WithCustomArgument("-flush_packets 1")
        //            .WithCustomArgument("-muxpreload 0")
        //            .WithCustomArgument("-muxdelay 0")
        //            .WithCustomArgument("-mpegts_flags +resend_headers+initial_discontinuity")
        //        )
        //        .CancellableThrough(cancellation)
        //        .ProcessAsynchronously();

        // Fehler aus FFmpeg loggen (ohne das Enumerator-Protokoll zu stören)
        _ = ffmpegTask.ContinueWith(
            t => _log.LogError(t.Exception!, "FFmpeg faulted for '{Dev}'", deviceName),
            TaskContinuationOptions.OnlyOnFaulted);

        // 5) Lesen -> ohne Allokationslawine: EIN Puffer, pro Iteration als Slice zurückgeben
        var buffer = new byte[32 * 1024]; // 32 KiB: guter Kompromiss zw. Overhead & Latenz

        try
        {
            while (!cancellation.IsCancellationRequested)
            {
                var read = await pipeClient.ReadAsync(buffer, 0, buffer.Length, cancellation);
                if (read <= 0) break;

                // Achtung: Der zurückgegebene Slice bleibt bis zur nächsten Iteration gültig.
                yield return new ReadOnlyMemory<byte>(buffer, 0, read);
            }

            // FFmpeg sauber beenden (wirft, wenn die Pipeline fehlgeschlagen ist)
            await ffmpegTask;
        }
        finally
        {
            _log.LogInformation("FFmpeg stream finished for '{Dev}'", deviceName);
        }
    }




/// <summary>
/// Nimmt einen einzelnen Frame als JPG oder PNG auf und liefert das Byte-Array.
/// </summary>
public async Task<byte[]> SnapshotAsync(
            string deviceName,
            int width,
            int height,
            string format,
            CancellationToken cancellation)
    {

        await using var ms = new MemoryStream();
        var sink = new StreamPipeSink(ms);

        var vcodec = format.Equals("png", StringComparison.OrdinalIgnoreCase)
            ? "png"
            : "mjpeg";

        await FFMpegArguments
            .FromDeviceInput($"\"video={deviceName}\"", opts => opts
                .WithCustomArgument("-f dshow")
                .WithCustomArgument("-rtbufsize 100M")
                .WithCustomArgument($"-video_size {width}x{height}")
                .WithCustomArgument("-pixel_format yuyv422"))
            .OutputToPipe(sink, opts => opts
                .WithCustomArgument("-frames:v 1")
                .WithCustomArgument("-update 1")
                .WithCustomArgument("-f image2pipe")
                .WithCustomArgument($"-vcodec {vcodec}"))
            .CancellableThrough(cancellation)
            .ProcessAsynchronously();

        return ms.ToArray();
    }

}

