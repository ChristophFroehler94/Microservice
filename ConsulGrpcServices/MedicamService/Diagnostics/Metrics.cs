using System.Collections.Concurrent;
using System.Diagnostics.Metrics;

namespace Medicam.Diagnostics;

/// <summary>
/// Zentrale Metriken (OpenTelemetry + lokaler Quantil-Schnappschuss für p50/p95/p99).
/// - Histogramme/Counter werden über /metrics (Prometheus) exportiert.
/// - Quantile-Snapshot (Rolling-Reservoir) kann ohne Prometheus über /diag/quantiles abgefragt werden.
/// </summary>
public static class Metrics
{
    public static readonly Meter Meter = new("medicam", "1.0.0");

    // ---- RPC ----
    public static readonly Histogram<double> RpcDurationMs =
        Meter.CreateHistogram<double>("medicam_rpc_duration_ms", unit: "ms",
            description: "Dauer von RPCs (gRPC-Server), je Methode/Status");

    public static readonly Counter<long> RpcRequestsTotal =
        Meter.CreateCounter<long>("medicam_rpc_requests_total", description: "Anzahl RPC-Requests");

    public static readonly Counter<long> RpcErrorsTotal =
        Meter.CreateCounter<long>("medicam_rpc_errors_total", description: "Anzahl RPC-Fehler (Status != OK)");

    public static readonly Counter<long> RpcDeadlineExceededTotal =
        Meter.CreateCounter<long>("medicam_rpc_deadline_exceeded_total", description: "Anzahl DEADLINE_EXCEEDED");

    // ---- VISCA / Serial ----
    public static readonly Counter<long> ViscaRetryTotal =
        Meter.CreateCounter<long>("medicam_visca_retry_total", description: "Wiederholungen je VISCA-Befehl");

    public static readonly Counter<long> ViscaPortReopenTotal =
        Meter.CreateCounter<long>("medicam_visca_port_reopen_total", description: "Port-Reopen-Ereignisse");

    public static readonly Histogram<double> ViscaCommandDurationMs =
        Meter.CreateHistogram<double>("medicam_visca_cmd_duration_ms", unit: "ms", description: "Dauer VISCA-Befehle");

    // ---- Streaming ----
    public static readonly UpDownCounter<long> ActiveStreams =
        Meter.CreateUpDownCounter<long>("medicam_stream_active", description: "Aktive TS-Streams");

    public static readonly Counter<long> StreamBytesTotal =
        Meter.CreateCounter<long>("medicam_stream_bytes_total", description: "Übertragene Bytes in Streams");

    // ---- Einfacher Rolling-Reservoir für lokale Quantile ----
    private const int ReservoirSize = 4096;

    private class Ring
    {
        private readonly double[] _a = new double[ReservoirSize];
        private int _idx;
        private int _count;
        private readonly object _lock = new();

        public void Add(double v)
        {
            lock (_lock)
            {
                _a[_idx] = v;
                _idx = (_idx + 1) % _a.Length;
                if (_count < _a.Length) _count++;
            }
        }

        public (double p50, double p95, double p99) Snapshot()
        {
            double[] copy;
            int c;
            lock (_lock)
            {
                c = _count;
                copy = new double[c];
                // linear kopieren (keine Sortierung nach Zeit nötig)
                int start = (_idx - c + _a.Length) % _a.Length;
                for (int i = 0; i < c; i++)
                    copy[i] = _a[(start + i) % _a.Length];
            }
            if (c == 0) return (double.NaN, double.NaN, double.NaN);
            Array.Sort(copy);
            double Q(double q)
            {
                if (c == 1) return copy[0];
                var pos = q * (c - 1);
                var lo = (int)Math.Floor(pos);
                var hi = (int)Math.Ceiling(pos);
                if (lo == hi) return copy[lo];
                return copy[lo] + (copy[hi] - copy[lo]) * (pos - lo);
            }
            return (Q(0.50), Q(0.95), Q(0.99));
        }
    }

    private static readonly ConcurrentDictionary<string, Ring> _rpcRings = new();

    public static void ObserveRpc(string method, double durationMs, string statusCode)
    {
        RpcDurationMs.Record(durationMs, KeyValuePair.Create<string, object?>("method", method),
                                            KeyValuePair.Create<string, object?>("status", statusCode));
        RpcRequestsTotal.Add(1, KeyValuePair.Create<string, object?>("method", method));
        if (!string.Equals(statusCode, "OK", StringComparison.OrdinalIgnoreCase))
            RpcErrorsTotal.Add(1, KeyValuePair.Create<string, object?>("method", method),
                                  KeyValuePair.Create<string, object?>("status", statusCode));
        var ring = _rpcRings.GetOrAdd(method, _ => new Ring());
        ring.Add(durationMs);
    }

    public static IDictionary<string, (double p50, double p95, double p99)> SnapshotQuantiles()
    {
        return _rpcRings.ToDictionary(
            kvp => kvp.Key,
            kvp => kvp.Value.Snapshot());
    }
}
