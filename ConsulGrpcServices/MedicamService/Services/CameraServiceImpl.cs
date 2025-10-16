using Camera.V1;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Medicam.Infrastructure;
using System.Diagnostics;

namespace Medicam.Service
{
    /// <summary>
    /// gRPC-Implementierung der Kamerasteuerung inkl. Streaming/Snapshot.
    /// </summary>
    public sealed class CameraServiceImpl : CameraService.CameraServiceBase
    {
        private readonly ILogger<CameraServiceImpl> _log;
        private readonly ViscaController _visca;
        private readonly FfmpegCoreVideoStream _videoStream;

        public CameraServiceImpl(ILogger<CameraServiceImpl> log,
                                 ViscaController visca,
                                 FfmpegCoreVideoStream videoStream)
        {
            _log = log;
            _visca = visca;
            _videoStream = videoStream;
        }

        public override async Task<StatusReply> Power(PowerRequest request, ServerCallContext context)
        {
            var sw = Stopwatch.StartNew();
            try
            {
                await _visca.PowerAsync(request.On);
                _log.LogInformation("Power {On} in {Ms} ms", request.On, sw.ElapsedMilliseconds);
                return new StatusReply { Ok = true, Message = request.On ? "Power ON" : "Standby" };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "Power failed after {Ms} ms", sw.ElapsedMilliseconds);
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }
        }

        public override async Task<StatusReply> Zoom(ZoomRequest request, ServerCallContext context)
        {
            var sw = Stopwatch.StartNew();
            try
            {
                if (request.Position > 0x7AC0)
                    throw new RpcException(new Status(StatusCode.InvalidArgument, "zoom.position out of range (max 0x7AC0)"));

                await _visca.ZoomDirectAsync((ushort)request.Position);
                _log.LogInformation("Zoom {Pos} in {Ms} ms", request.Position, sw.ElapsedMilliseconds);
                return new StatusReply { Ok = true, Message = "OK" };
            }
            catch (RpcException)
            {
                throw;
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "Zoom failed after {Ms} ms", sw.ElapsedMilliseconds);
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }
        }

        public override async Task<CameraStatus> GetStatus(Empty request, ServerCallContext context)
        {
            try
            {
                bool on = await _visca.PowerInquiryAsync();
                ushort zoom = await _visca.ZoomPosInquiryAsync();
                return new CameraStatus { PoweredOn = on, ZoomPos = zoom };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "GetStatus failed");
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }
        }

        public override async Task StreamTs(
            StreamH264Request request,
            IServerStreamWriter<TsChunk> responseStream,
            ServerCallContext context)
        {
            responseStream.WriteOptions = new WriteOptions(WriteFlags.NoCompress);

            string id = Guid.NewGuid().ToString("N")[..8];
            var sw = Stopwatch.StartNew();
            long bytes = 0, chunks = 0;

            _log.LogInformation("StreamTs START {Id} {W}x{H}@{Fps} bitrate={Bitrate}",
                id, request.Width, request.Height, request.Fps, request.Bitrate);

            try
            {
                await foreach (var segment in _videoStream.StreamTsAsync(
                                   request.Width, request.Height, request.Fps, request.Bitrate, context.CancellationToken))
                {
                    var bs = Google.Protobuf.UnsafeByteOperations.UnsafeWrap(segment);
                    await responseStream.WriteAsync(new TsChunk { Data = bs }, context.CancellationToken);
                    bytes += segment.Length; chunks++;
                }

                _log.LogInformation("StreamTs END {Id} dur={S:n1}s chunks={C} bytes={B}",
                    id, sw.Elapsed.TotalSeconds, chunks, bytes);
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

        public override async Task<SnapshotReply> TakeSnapshot(SnapshotRequest request, ServerCallContext context)
        {
            int width = request.Width > 0 ? request.Width : 1920;
            int height = request.Height > 0 ? request.Height : 1080;
            string format = request.Format?.ToLower() == "png" ? "png" : "jpg";

            try
            {
                byte[] image = await _videoStream.SnapshotAsync(
                    width: width,
                    height: height,
                    format: format,
                    cancellation: context.CancellationToken);

                return new SnapshotReply
                {
                    Image = Google.Protobuf.ByteString.CopyFrom(image),
                    Timestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
                };
            }
            catch (Exception ex)
            {
                _log.LogError(ex, "Snapshot failed");
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }
        }
    }
}
