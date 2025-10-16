// ----------------------------------------------
// Interop: COM-Port-Autodetektion (FTDI VID_0403/PID_6001) via WMI
// - Funktioniert nur unter Windows (TargetFramework: net8.0-windows)
// ----------------------------------------------

using System.Management;
using System.Text.RegularExpressions;

namespace Medicam.Interop
{
    public static class SerialPorts
    {
        public static string? AutoDetectFtdiComPort()
        {
            try
            {
                using var searcher = new ManagementObjectSearcher(
                    "SELECT Name, PNPDeviceID FROM Win32_PnPEntity WHERE Name LIKE '%(COM%'");

                foreach (var mo in searcher.Get())
                {
                    string name = mo["Name"]?.ToString() ?? "";
                    string pnp = mo["PNPDeviceID"]?.ToString() ?? "";

                    bool isFtdi = pnp.Contains("VID_0403", StringComparison.OrdinalIgnoreCase)
                               && pnp.Contains("PID_6001", StringComparison.OrdinalIgnoreCase);

                    if (!isFtdi) continue;

                    var m = Regex.Match(name, @"\((COM\d+)\)");
                    if (m.Success) return m.Groups[1].Value;
                }
            }
            catch
            {
                // Ignorieren → Fallback in Program.cs/ViscaController
            }
            return null;
        }
    }
}
