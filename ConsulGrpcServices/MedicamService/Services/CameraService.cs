using Camera.V1;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Microsoft.Extensions.Logging.Abstractions;
using System.Diagnostics;
using System.Runtime.ConstrainedExecution;

namespace Camera.Grpc.Service
{
    public sealed class CameraServiceImpl : CameraService.CameraServiceBase
    {
        private readonly ILogger<CameraServiceImpl> _log;
        private readonly ViscaController _visca;
        private readonly FfmpegCoreVideoStream _videoStream;  // neu

        public CameraServiceImpl(
            ILogger<CameraServiceImpl> log,
            ViscaController visca,
            FfmpegCoreVideoStream videoStream)           // Injection
        {
            _log = log ?? NullLogger<CameraServiceImpl>.Instance;
            _visca = visca;
            _videoStream = videoStream;
        }

        public override async Task<StatusReply> Power(PowerRequest request, ServerCallContext context)
        {
            try
            {
                await _visca.PowerAsync(request.On);
                return new StatusReply { Ok = true, Message = request.On ? "Power ON" : "Standby" };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "Power failed");
                return new StatusReply { Ok = false, Message = ex.Message };
            }
        }

        public override async Task<StatusReply> Zoom(ZoomRequest request, ServerCallContext context)
        {
            try
            {
                switch (request.KindCase)
                {
                    case ZoomRequest.KindOneofCase.Direct:
                        await _visca.ZoomDirectAsync((ushort)request.Direct);
                        break;
                    case ZoomRequest.KindOneofCase.Variable:
                        var tele = request.Variable.Dir == ZoomRequest.Types.SidedSpeed.Types.Direction.Tele;
                        var speed = (byte)request.Variable.Speed;
                        await _visca.ZoomVariableAsync(tele, speed);
                        break;
                    case ZoomRequest.KindOneofCase.Stop:
                        await _visca.ZoomStopAsync();
                        break;
                    default:
                        throw new RpcException(new Status(StatusCode.InvalidArgument, "zoom: invalid argument"));
                }
                return new StatusReply { Ok = true, Message = "OK" };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "Zoom failed");
                return new StatusReply { Ok = false, Message = ex.Message };
            }
        }

        public override async Task<StatusReply> SetFocusMode(SetFocusModeRequest request, ServerCallContext context)
        {
            try
            {
                var auto = request.Mode == SetFocusModeRequest.Types.Mode.Auto;
                await _visca.SetFocusModeAsync(auto);
                return new StatusReply { Ok = true, Message = auto ? "AF" : "MF" };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "SetFocusMode failed");
                return new StatusReply { Ok = false, Message = ex.Message };
            }
        }

        public override async Task<StatusReply> SetFocusPosition(SetFocusPositionRequest request, ServerCallContext context)
        {
            try
            {
                await _visca.FocusDirectAsync((ushort)request.Direct);
                return new StatusReply { Ok = true, Message = "OK" };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "SetFocusPosition failed");
                return new StatusReply { Ok = false, Message = ex.Message };
            }
        }

        public override async Task<CameraStatus> GetStatus(Empty request, ServerCallContext context)
        {
            try
            {
                var on = await _visca.PowerInquiryAsync();
                var zoom = await _visca.ZoomPosInquiryAsync();
                var focus = await _visca.FocusPosInquiryAsync();
                return new CameraStatus { PoweredOn = on, ZoomPos = zoom, FocusPos = focus };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "GetStatus failed");
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }
        }

        public override async Task StreamTs(StreamH264Request request,
            IServerStreamWriter<TsChunk> responseStream,
            ServerCallContext context)
        {
            responseStream.WriteOptions = new WriteOptions(WriteFlags.NoCompress);

            var id = Guid.NewGuid().ToString("N")[..8];
            var sw = System.Diagnostics.Stopwatch.StartNew();
            long bytes = 0, chunks = 0, lastBytes = 0;
            var last = sw.Elapsed;

            _log.LogInformation("StreamTs START {Id} dev='{Dev}' {W}x{H}@{Fps} bitrate={Bitrate}",
                id, request.DeviceId, request.Width, request.Height, request.Fps, request.Bitrate);

            try
            {
                await foreach (var segment in _videoStream.StreamTsAsync(
                                   request.DeviceId, request.Width, request.Height,
                                   request.Fps, request.Bitrate, context.CancellationToken))
                {
                    //await responseStream.WriteAsync(new TsChunk
                    //{
                    //    Data = Google.Protobuf.ByteString.CopyFrom(segment)
                    //});
                    var bs = Google.Protobuf.UnsafeByteOperations.UnsafeWrap(segment);
                    await responseStream.WriteAsync(new TsChunk { Data = bs });
                    bytes += segment.Length; chunks++;

                    var now = sw.Elapsed;
                    if ((now - last).TotalSeconds >= 5)
                    {
                        var delta = bytes - lastBytes;
                        var mbit = (delta * 8.0) / (now - last).TotalSeconds / 1_000_000.0;
                        _log.LogDebug("StreamTs {Id} throughput={M:F2} Mbit/s total={MB:F1} MB chunks={C}",
                            id, mbit, bytes / (1024.0 * 1024.0), chunks);
                        last = now; lastBytes = bytes;
                    }
                }

                _log.LogInformation("StreamTs END {Id} dur={S:n1}s chunks={C} bytes={B} avg={M:F2} Mbit/s",
                    id, sw.Elapsed.TotalSeconds, chunks, bytes,
                    (bytes * 8.0) / sw.Elapsed.TotalSeconds / 1_000_000.0);
            }
            catch (RpcException ex) when (ex.StatusCode == StatusCode.Cancelled)
            {
                _log.LogInformation("StreamTs CANCELLED {Id} after {S:n1}s", id, sw.Elapsed.TotalSeconds);
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "StreamTs FAILED {Id} after {S:n1}s chunks={C} bytes={B}",
                    id, sw.Elapsed.TotalSeconds, chunks, bytes);
                throw;
            }
        }


        private static Task LogStatsPeriodically(
        ILogger log, string id, Func<long> bytes, Func<long> chunks, Stopwatch sw, CancellationToken ct)
        {
            return Task.Run(async () =>
            {
                long lastBytes = 0;
                var lastTs = TimeSpan.Zero;
                while (!ct.IsCancellationRequested)
                {
                    await Task.Delay(TimeSpan.FromSeconds(5), ct);
                    var b = bytes();
                    var c = chunks();
                    var dt = sw.Elapsed - lastTs;
                    var delta = b - lastBytes;
                    var mbitps = (delta * 8.0) / Math.Max(0.001, dt.TotalSeconds) / 1_000_000.0;

                    log.LogDebug("StreamTs {Id} throughput={Mbit:F2} Mbit/s total={MB:F1} MB chunks={Chunks}",
                        id, mbitps, b / (1024.0 * 1024.0), c);

                    lastBytes = b;
                    lastTs = sw.Elapsed;
                }
            }, ct);
        }

        public override async Task<SnapshotReply> TakeSnapshot(
                SnapshotRequest request,
                ServerCallContext context)
        {
            var width = request.Width > 0 ? request.Width : 1920;
            var height = request.Height > 0 ? request.Height : 1080;
            var format = request.Format?.ToLower() == "png" ? "png" : "jpg";

            byte[] image;
            try
            {
                image = await _videoStream.SnapshotAsync(
                    deviceName: request.DeviceId,
                    width: width,
                    height: height,
                    format: format,
                    cancellation: context.CancellationToken);
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "Snapshot failed");
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }

            return new SnapshotReply
            {
                Image = Google.Protobuf.ByteString.CopyFrom(image),
                Timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
            };
        }
    }
}

