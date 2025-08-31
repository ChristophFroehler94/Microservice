using FotoFinder.PolFlashXe.FlashViscaComHandler;
using FotoFinder.PolFlashXE.FlashDevices.Settings;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FotoFinder.PolFlashXE.FlashDevices
{
    public class PolFlashXeV1 : IFlashDevice
    {
        // fields
        private FlashViscaComHandler ViscaHandler;

        // attributes
        public Version HwVersion { get; private set; } = new Version(0,1);
        public Version SwVersion { get; private set; }

        // connection status
        public bool IsInitialized { get; private set; } = false;

        public FlashState DeviceState { get; private set; }

        // flash tube parameters
        public PolarizationModes LeftPolarizationMode { get; private set; }
        public PolarizationModes RightPolarizationMode { get; private set; }
        public double FlashEnergyLeft { get; private set; }
        public double FlashEnergyRight { get; private set; }

        public string ComPort { get; private set; }

        // event handler
        public event EventHandler<FlashState> StateChanged = delegate { };
        public event EventHandler ReadyToFlash = delegate { };
        public event EventHandler Waiting = delegate { };

        /// <summary>
        /// constructor for PolFlashXeV1 class
        /// </summary>
        /// <param name="comHandler"></param>
        public PolFlashXeV1(FlashViscaComHandler comHandler)
        {
            // configure visca handler
            ViscaHandler = comHandler;
            ComPort = comHandler.ComPort.PortName;
            ViscaHandler.NotificationReceived += NotificationHandler;
        }

        /// <summary>
        /// Handle notification messages from visca communication handler
        /// </summary>
        private void NotificationHandler(object sender, byte[] notification)
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
                        // this command is broken, it is mixed up with the acknowledge message
                        // tryed to charge without supply voltage                  
                    }
                    break;              
                // Event received
                case 0x0E:
                    // findout what event has occured
                    if (notification[2] == 0x21)
                    {
                        // ready to flash event
                        DeviceState = FlashState.ready;
                        ReadyToFlash(null, EventArgs.Empty);
                    }
                    else if (notification[2] == 0x41)
                    {
                        // focus laser auto switch off engaged
                        throw new NotImplementedException("Laser Toggled off!");
                    }
                    else if (notification[2] == 0x99)
                    {
                        // auto discharge finished, device ready again
                        DeviceState = FlashState.ready;
                        throw new NotImplementedException("Auto Discharge Occured?");

                    }
                    break;
                default:
                    break;
            }
        }

        /// <summary>
        /// Initialize class attributes
        /// </summary>
        public void Initialize()
        {
            // request data from polflash
            GetSoftwareVersion();
            GetFlashEnergy();
            GetPolarizationMode();
        }

        public void Connect()
        {
            ViscaHandler.Connect(ViscaHandler.ComPort.PortName);
        }

        public void Charge()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x21, 0x01, 0xFF };

            // send Message
            SendAndCheck(sendMsg, 5);

            // check for mixed in reply message
            if(sendMsg.Reply[3] == 0x02)
            {
                throw new ApplicationException("No supply voltage, charging not possible!");
            }
        }

        public void Discharge()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x01, 0x21, 0x00, 0xFF };

            // send Message
            SendAndCheck(sendMsg, 5);
        }

        public void Disconnect()
        {
            ViscaHandler.Disconnect();
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

        public void GetStateMaschine()
        {
            ViscaMessage sendMsg = new ViscaMessage();
            sendMsg.Command = new byte[] { 0x30, 0x09, 0x51, 0xFF };

            // Send Message
            SendAndCheck(sendMsg, 5);

            // check reply for correct format
            DeviceState = (FlashState)(sendMsg.Reply[3]);
        }

        // Non Interface Methods
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
