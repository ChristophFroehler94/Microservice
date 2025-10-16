// ----------------------------------------------
// Diagnostik / Telemetrie
// - Thread-sicheres Sliding-Window je RPC-Methode
// - Erzeugt p95/p99, Fehlerraten, Gesamtzähler
// - Dient als Grundlage für Kapitel-5-Messungen
// ----------------------------------------------

using System.Collections.Concurrent;
using System.Diagnostics.Metrics;

namespace Medicam.Diagnostics
{
    public static class Telemetry
    {
        // .NET Meter/Instrumente (nutzbar für OTEL/Prometheus, falls gewünscht)
        public static readonly Meter Meter = new("medicam.service");
        public static readonly Histogram<double> RpcDurationMs = Meter.CreateHistogram<double>(
            "rpc_duration_ms",
            unit: "ms",
            description: "Dauer je gRPC-Call (Ende-zu-Ende, inkl. Serververarbeitung).");

        public static readonly Counter<long> RpcErrorCount = Meter.CreateCounter<long>(
            "rpc_errors_total",
            description: "Fehlerhafte gRPC-Calls (Status != OK).");

        // In-Memory-Sliding-Window für einfache p95/p99 je Methode
        private const int WindowSize = 4096;

        private sealed class Window
        {
            public long TotalCalls;
            public long ErrorCalls;
            public ConcurrentQueue<double> Samples = new();
        }

        private static readonly ConcurrentDictionary<string, Window> _byMethod = new(StringComparer.Ordinal);

        public static void Record(string method, bool ok, double durationMs)
        {
            var w = _byMethod.GetOrAdd(method, _ => new Window());
            Interlocked.Increment(ref w.TotalCalls);
            if (!ok) Interlocked.Increment(ref w.ErrorCalls);

            // Histogram/Counter publizieren (für externe Exporter)
            RpcDurationMs.Record(durationMs);
            if (!ok) RpcErrorCount.Add(1);

            // Sliding-Window (Begrenzung)
            w.Samples.Enqueue(durationMs);
            while (w.Samples.Count > WindowSize && w.Samples.TryDequeue(out _)) { }
        }

        public static object GetSnapshotAndReset()
        {
            var result = new Dictionary<string, object>(StringComparer.Ordinal);

            foreach (var kv in _byMethod)
            {
                var method = kv.Key;
                var w = kv.Value;

                var arr = w.Samples.ToArray();
                Array.Sort(arr);
                double p95 = Percentile(arr, 95);
                double p99 = Percentile(arr, 99);

                result[method] = new
                {
                    total = Interlocked.Read(ref w.TotalCalls),
                    errors = Interlocked.Read(ref w.ErrorCalls),
                    p95_ms = p95,
                    p99_ms = p99,
                    sample_count = arr.Length
                };

                // optionaler Reset → definiert Messfenster (für reproduzierbare Läufe)
                Interlocked.Exchange(ref w.TotalCalls, 0);
                Interlocked.Exchange(ref w.ErrorCalls, 0);
                while (w.Samples.TryDequeue(out _)) { }
            }

            return new
            {
                service = "Medicam.CameraService",
                timestamp_utc = DateTime.UtcNow,
                methods = result
            };
        }

        private static double Percentile(double[] sorted, int p)
        {
            if (sorted.Length == 0) return 0;
            if (p <= 0) return sorted[0];
            if (p >= 100) return sorted[^1];

            double rank = (p / 100.0) * (sorted.Length - 1);
            int lo = (int)Math.Floor(rank);
            int hi = (int)Math.Ceiling(rank);
            if (lo == hi) return sorted[lo];
            double frac = rank - lo;
            return sorted[lo] + frac * (sorted[hi] - sorted[lo]);
        }
    }
}
