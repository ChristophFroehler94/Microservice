// ----------------------------------------------
// gRPC Interceptor für E2E-Messungen
// - Misst Dauer und Status je Call
// - Schreibt in Telemetry-Sliding-Window
// ----------------------------------------------

using Grpc.Core;
using Grpc.Core.Interceptors;

namespace Medicam.Diagnostics
{
    public sealed class GrpcMetricsInterceptor : Interceptor
    {
        public override async Task<TResponse> UnaryServerHandler<TRequest, TResponse>(
            TRequest request,
            ServerCallContext context,
            UnaryServerMethod<TRequest, TResponse> continuation)
        {
            var sw = System.Diagnostics.Stopwatch.StartNew();
            StatusCode code = StatusCode.OK;
            try
            {
                var resp = await continuation(request, context);
                return resp;
            }
            catch (RpcException ex)
            {
                code = ex.StatusCode;
                throw;
            }
            catch
            {
                code = StatusCode.Unknown;
                throw;
            }
            finally
            {
                sw.Stop();
                var ok = code == StatusCode.OK;
                var method = context.Method ?? "unknown";
                Telemetry.Record(method, ok, sw.Elapsed.TotalMilliseconds);
            }
        }

        public override async Task ServerStreamingServerHandler<TRequest, TResponse>(
            TRequest request,
            IServerStreamWriter<TResponse> responseStream,
            ServerCallContext context,
            ServerStreamingServerMethod<TRequest, TResponse> continuation)
        {
            var sw = System.Diagnostics.Stopwatch.StartNew();
            StatusCode code = StatusCode.OK;
            try
            {
                await continuation(request, responseStream, context);
            }
            catch (RpcException ex)
            {
                code = ex.StatusCode;
                throw;
            }
            catch
            {
                code = StatusCode.Unknown;
                throw;
            }
            finally
            {
                sw.Stop();
                var ok = code == StatusCode.OK;
                var method = context.Method ?? "unknown";
                Telemetry.Record(method, ok, sw.Elapsed.TotalMilliseconds);
            }
        }
    }
}
