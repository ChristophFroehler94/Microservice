using System;
using System.Threading.Tasks;

using FotoFinder.PolFlashXe.FlashViscaComHandler;
using FotoFinder.PolFlashXE.FlashDevices.Settings;

namespace FotoFinder.PolFlashXE.FlashDevices
{
    public class PolFlashXeV2 : IFlashDevice2
    {
        // Fields
        private FlashViscaComHandler ViscaHandler;

        // Attributes
        public int FlashCount { get; private set; }
        public Version HwVersion { get; private set; }
        public Version SwVersion { get; private set; }
        public double FlashEnergyRight { get; private set; }
        public double FlashEnergyLeft { get; private set; }
        public PolarizationModes RightPolarizationMode { get; private set; }
        public PolarizationModes LeftPolarizationMode { get; private set; }
        public string ComPort { get; private set; }
        public FlashState DeviceState { get; private set; }
        public bool IsInitialized { get; private set; } = false;

        // Events
        public event EventHandler<FlashState> StateChanged = delegate { };
        public event EventHandler ReadyToFlash = delegate { };
        public event EventHandler Waiting = delegate { };

        // constructor
        public PolFlashXeV2(FlashViscaComHandler viscaHandler, Version SwVersion = null)
        {
            ViscaHandler = viscaHandler;
            ComPort = viscaHandler.ComPort.PortName;
            this.SwVersion = SwVersion;

            ViscaHandler.NotificationReceived += FlashV2NotificationHandler;
        }

        private void FlashV2NotificationHandler(object sender, byte[] notification)
        {
            switch (notification[1])
            {
                // Error?
                case 0x0A:
                    // findout what error event has occured
                    if (notification[2] == 0x21 && notification[3] == 0x01)
                    {
                        throw new NotImplementedException("Auto Discharge Occured?");
                    }
                    else if (notification[2] == 0x21 && notification[3] == 0x02)
                    {
                        // tryed to charge without supply voltage
                        throw new ApplicationException("Cannot Charge, No Supply Volate");
                    }
                    break;
                case 0x0C:
                    DeviceState = (FlashState)(notification[2]);
                    if (DeviceState == FlashState.ready)
                    {
                        ReadyToFlash(null, EventArgs.Empty);
                    }
                    else if (DeviceState == FlashState.wait)
                    {
                        Waiting(null, EventArgs.Empty);
                    }
                    StateChanged(null, DeviceState);
                    break;
                // Event received
                case 0x0E:
                    // finout what event has occured
                    if (notification[2] == 0x41)
                    {
                        // focus laser auto switch off engaged
                        throw new NotImplementedException("Laser Toggled off!");
                    }
                    else if (notification[2] == 0x99)
                    {
                        // auto discharge engaged
                        throw new NotImplementedException("Auto Discharge Occured?");
                    }
                    break;
                default:
                    break;
            }
        }

        public void Connect()
        {
            ViscaHandler.Connect(ViscaHandler.ComPort.PortName);
        }

        public void Disconnect()
        {
            ViscaHandler.Disconnect();
        }

        public void Initialize()
        {
            // initialize 
            if (SwVersion == null)
            {
                GetSoftwareVersion();
            }

            GetHardwareVersion();
            GetFlashEnergy();
            GetPolarizationMode();
            GetStateMaschine();
            GetFlashCount();

            IsInitialized = true;
        }

        // Methods
        public void Charge()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x21, 0x01, 0xFF };

            // send Message
            SendAndCheck(sendMsg, 5);
        }

        public void Discharge()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x21, 0x00, 0xFF };

            // send Message
            SendAndCheck(sendMsg, 5);
        }

        public void SetFlashEnergy(double PercentageRight, double PercentageLeft)
        {
            // convert values to integer
            int FlashEnergyRight = Convert.ToInt32(PercentageRight * 255.0 / 100.0);
            int FlashEnergyLeft = Convert.ToInt32(PercentageLeft * 255.0 / 100.0);

            // assert parameters
            if ((FlashEnergyRight < 0 && FlashEnergyRight > 100) ||
               (FlashEnergyLeft < 0 && FlashEnergyLeft > 100))
            {
                throw new ApplicationException("Flash Power Percentage out of Range");
            }

            // create message
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x11, 0x00, 0x00, 0x00, 0x00, 0xFF };
            sendMsg.Command[3] = (byte)((FlashEnergyRight >> 4) & 0xF);
            sendMsg.Command[4] = (byte)((FlashEnergyRight >> 0) & 0xF);
            sendMsg.Command[5] = (byte)((FlashEnergyLeft >> 4) & 0xF);
            sendMsg.Command[6] = (byte)((FlashEnergyLeft >> 0) & 0xF);

            // send Message
            SendAndCheck(sendMsg, 5);

            // save in class
            this.FlashEnergyRight = PercentageRight;
            this.FlashEnergyLeft = PercentageLeft;
        }

        public void SetLaser(bool IsActive)
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x41, (byte)(IsActive ? 0x01 : 0x00), 0xFF };

            // Send the Message
            SendAndCheck(sendMsg, 5);
        }

        public void SetPolarization(PolarizationModes RightMode, PolarizationModes LeftMode)
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x31, 0x00, 0x00, 0xFF };
            sendMsg.Command[3] = (byte)(RightMode == PolarizationModes.polarized ? 0x01 : 0x00);
            sendMsg.Command[4] = (byte)(LeftMode == PolarizationModes.polarized ? 0x01 : 0x00);

            // Send the Message
            SendAndCheck(sendMsg, 5);

            // Save Values
            RightPolarizationMode = RightMode;
            LeftPolarizationMode = LeftMode;
        }

        public void Trigger()
        {
            FlashState OldState = DeviceState;

            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x51, 0xFF };

            // Send the Message
            SendAndCheck(sendMsg, 5);

            if(OldState == FlashState.ready)
            {
                FlashCount++;
            }
        }

        public void GetPolarizationMode()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x31, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 6);

            // check reply for correct format
            RightPolarizationMode = (sendMsg.Reply[3] == 0x01 ? PolarizationModes.polarized : PolarizationModes.unpolarized);
            LeftPolarizationMode = (sendMsg.Reply[3] == 0x01 ? PolarizationModes.polarized : PolarizationModes.unpolarized);
        }

        public void GetFlashEnergy()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x11, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 8);

            // check reply for correct format
            FlashEnergyRight = (100.0 / 255.0) * ((sendMsg.Reply[3] << 4) + sendMsg.Reply[4]);
            FlashEnergyLeft = (100.0 / 255.0) * ((sendMsg.Reply[5] << 4) + sendMsg.Reply[6]);
        }

        public void GetSoftwareVersion()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x01, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 6);

            // check reply for correct format
            SwVersion = new Version(sendMsg.Reply[3], sendMsg.Reply[4]);
        }

        public void GetHardwareVersion()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x02, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 6);

            // check reply for correct format
            HwVersion = new Version(sendMsg.Reply[3], sendMsg.Reply[4]);
        }

        public void GetStateMaschine()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x51, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 5);

            // check reply for correct format
            DeviceState = (FlashState)(sendMsg.Reply[3]);
        }

        public bool GetVccp()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x61, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 5);

            // check reply for correct format
            return (1 == sendMsg.Reply[3]);
        }

        public void ResetFlashCount()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x71, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 5);
        }

        public int GetFlashCount()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x71, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 8);

            // check byte 6 for eeprom error
            if (sendMsg.Reply[6] == 0x00)
            {
                FlashCount = (sendMsg.Reply[3] << 16) | (sendMsg.Reply[4] << 8) | (sendMsg.Reply[5]); 
                return FlashCount;
            }
            else
            {
                return -1;
            }
        }

        private void SendAndCheck(ViscaMessage msg, int ReplyLeng)
        {
            // Send Message
            ViscaHandler.SendReceive(msg);

            // check reply for correct format
            if (msg.Reply == null ||
                msg.Reply.Length != ReplyLeng ||
                msg.Reply[0] != msg.Command[0] ||
                msg.Reply[1] != msg.Command[1] ||
                msg.Reply[2] != msg.Command[2])
            {
                throw new ApplicationException($"Invalid Reply Message {msg.ReplyToString()}");
            }
        }

    }
}
