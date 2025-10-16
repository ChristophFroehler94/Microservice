using FFMpegCore;
using FFMpegCore.Pipes;
using Medicam.Diagnostics;
using Microsoft.Extensions.Logging.Abstractions;
using System.IO.Pipes;
using System.Runtime.CompilerServices;

namespace Medicam.Infrastructure;

/// <summary>
/// H.264 → MPEG-TS Streaming per FFmpeg (DirectShow).
/// - Metriken: aktive Streams, Byte-Zähler.
/// - Gate limitiert parallele Streams (reproduzierbare Messungen).
/// </summary>
public sealed class FfmpegCoreVideoStream
{
    private readonly ILogger<FfmpegCoreVideoStream> _log;
    private readonly string _defaultDeviceName;
    private readonly SemaphoreSlim _streamGate = new(1, 1);

    public FfmpegCoreVideoStream(string defaultDeviceName, ILogger<FfmpegCoreVideoStream>? log = null)
    {
        _defaultDeviceName = defaultDeviceName;
        _log = log ?? NullLogger<FfmpegCoreVideoStream>.Instance;
    }

    public async IAsyncEnumerable<ReadOnlyMemory<byte>> StreamTsAsync(
        int width, int height, int fps, int bitrate, [EnumeratorCancellation] CancellationToken cancellation)
    {
        await _streamGate.WaitAsync(cancellation);
        string pipeName = Guid.NewGuid().ToString("N");
        Metrics.ActiveStreams.Add(1);

        try
        {
            await using var pipeServer = new NamedPipeServerStream(pipeName, PipeDirection.Out, 1, PipeTransmissionMode.Byte, PipeOptions.Asynchronous);
            using var pipeClient = new NamedPipeClientStream(".", pipeName, PipeDirection.In, PipeOptions.Asynchronous);

            await Task.WhenAll(pipeServer.WaitForConnectionAsync(cancellation), pipeClient.ConnectAsync(cancellation));

            var sink = new StreamPipeSink(pipeServer);

            _log.LogInformation("FFmpeg START dev='{Dev}' {W}x{H}@{Fps} bitrate={Bitrate}",
                _defaultDeviceName, width, height, fps, bitrate);

            int vbv = Math.Max(250_000, bitrate / 2);
            string x264Params = string.Join(":", new[]
            { "scenecut=0", "rc-lookahead=0", $"keyint={fps}", $"min-keyint={fps}", "intra-refresh=1", "nal-hrd=cbr" });

            var ffmpegTask =
                FFMpegArguments
                    .FromDeviceInput($"\"video={_defaultDeviceName}\"", opts => opts
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
                        .WithCustomArgument($"-g {fps}")
                        .WithCustomArgument($"-x264-params {x264Params}")
                        .WithCustomArgument($"-b:v {bitrate}")
                        .WithCustomArgument($"-maxrate {bitrate}")
                        .WithCustomArgument($"-bufsize {vbv}")
                        .WithCustomArgument("-pix_fmt yuv420p")
                        .WithCustomArgument("-f mpegts")
                        .WithCustomArgument("-fflags +nobuffer")
                        .WithCustomArgument("-avioflags direct")
                        .WithCustomArgument("-flush_packets 1")
                        .WithCustomArgument("-muxpreload 0")
                        .WithCustomArgument("-muxdelay 0")
                        .WithCustomArgument("-mpegts_flags +resend_headers+initial_discontinuity"))
                    .CancellableThrough(cancellation)
                    .ProcessAsynchronously();

            var buffer = new byte[32 * 1024];

            try
            {
                while (!cancellation.IsCancellationRequested)
                {
                    int read = await pipeClient.ReadAsync(buffer, 0, buffer.Length, cancellation);
                    if (read <= 0) break;

                    Metrics.StreamBytesTotal.Add(read);
                    yield return new ReadOnlyMemory<byte>(buffer, 0, read);
                }
                await ffmpegTask;
            }
            finally { _log.LogInformation("FFmpeg stream finished for '{Dev}'", _defaultDeviceName); }
        }
        finally
        {
            Metrics.ActiveStreams.Add(-1);
            _streamGate.Release();
        }
    }

    public async Task<byte[]> SnapshotAsync(int width, int height, string format, CancellationToken cancellation)
    {
        await using var ms = new MemoryStream();
        var sink = new StreamPipeSink(ms);
        string vcodec = format.Equals("png", StringComparison.OrdinalIgnoreCase) ? "png" : "mjpeg";

        await FFMpegArguments
            .FromDeviceInput($"\"video={_defaultDeviceName}\"", opts => opts
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
