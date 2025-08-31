using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Threading.Tasks;

using FotoFinder.PolFlashXe.FlashViscaComHandler;

namespace FotoFinder.PolFlashXE.FlashDevices
{
    public static class FlashDeviceFactory
    {
        // thread save device list
        private static ConcurrentBag<IFlashDevice> DeviceList = new ConcurrentBag<IFlashDevice>();

        /// <summary>
        /// Refreshes the DeviceList by first Disconnecting to all currently listed devices 
        /// and then searching again from scratch
        /// </summary>
        /// <returns> a list FlashDevices found by the refresh </returns>
        public static async Task<List<IFlashDevice>> RefreshDeviceListAsync()
        {
            // Clear existing list
            DisconnectAll();
            
            // Liste von allen verfügbaren COM-Ports erstellen
            List<string> comPorts = new List<string>(SerialPort.GetPortNames());
            
            // Liste von Tasks für die Verbindungen
            List<Task> connectTasks = comPorts.Select(name => ScanPortForFlashDeviceAsync(name)).ToList();

            // overall task of connecting everything, required to 
            // gather all thrown exceptions in one AggregateException 
            Task OverallTask = null;

            // Verbindung zu jedem Port herstellen
            try
            {
                // Warten, bis alle Verbindungen abgeschlossen sind
                OverallTask = Task.WhenAll(connectTasks);
                await OverallTask;
            }
            catch (Exception)
            {
                throw OverallTask.Exception;
            }

            return DeviceList.ToList();
        }

        /// <summary>
        /// Get the list of devices from last refresh
        /// </summary>
        /// <returns> list of FlashDevices </returns>
        public static List<IFlashDevice> GetDeviceList()
        {
            return DeviceList.ToList();
        }

        /// <summary>
        /// Disconnect all Devices in Device List and clear it
        /// </summary>
        public static void DisconnectAll()
        {
            // Disconnect all devices
            foreach (IFlashDevice device in DeviceList)
            {
                device.Disconnect();
            }

            // Reset List
            DeviceList = new ConcurrentBag<IFlashDevice>();
        }

        /// <summary>
        /// Returns the first device from the DeviceList which matches the required Type
        /// </summary>
        /// <typeparam name="T">Required type of FlashDevice</typeparam>
        /// <returns></returns>
        public static T GetDevice<T>() where T: IFlashDevice
        {
            foreach (IFlashDevice device in DeviceList)
            {
                if (device is T)
                {
                    return (T)device;
                }
            }
            return default(T); // returns null
        }

        /// <summary>
        /// Tries to connect to a flashdevice using the past comport and adds it to
        /// Device List if successfull.
        /// </summary>
        /// <param name="port">Connect to this com port</param>
        /// <returns></returns>
        public static async Task ScanPortForFlashDeviceAsync(string port)
        {
            IFlashDevice newDevice = null;
            FlashViscaComHandler comHandler = new FlashViscaComHandler();

            try
            {
                // try connecting
                comHandler.Connect(port);

                // Send Inquiry for software version to test connection
                ViscaMessage SwVersionInquiry = new ViscaMessage();
                SwVersionInquiry.Command = new byte[] { 0x30, 0x09, 0x01, 0xFF };

                // send software version inquiry and wait for reply
                comHandler.SendReceive(SwVersionInquiry);

                // check if success
                if (SwVersionInquiry.Reply.Length == 6 &&
                    SwVersionInquiry.Reply[0] == 0x30 &&
                    SwVersionInquiry.Reply[1] == 0x09 &&
                    SwVersionInquiry.Reply[2] == 0x01)
                {
                    // check content of reply
                    Version swVersion = new Version(SwVersionInquiry.Reply[3], SwVersionInquiry.Reply[4]);

                    switch (swVersion.ToString())
                    {
                        case "0.1":
                            newDevice = new PolFlashXeV1(comHandler);
                            await Task.Run(() => newDevice.Initialize());
                            DeviceList.Add(newDevice);
                            break;
                        case "0.2":
                            newDevice = new PolFlashXeV2(comHandler, swVersion);
                            await Task.Run(() => newDevice.Initialize());
                            DeviceList.Add(newDevice);
                            break;
                        default:                      
                            break;
                    }
                }
            }
            catch (Exception e) when (
                       e is UnauthorizedAccessException
                    || e is ApplicationException
                    || e is IOException           // Semaphore‐Timeout
                    || e is TimeoutException       // WriteTimeout oder ReadTimeout
                )
            {
                // Port busy / kein VISCA-Gerät / Timeout ⇒ einfach ignorieren
            }
            finally
            {
                if (newDevice == null)
                {
                    comHandler.Disconnect();
                }
            }
        }
    }
}
