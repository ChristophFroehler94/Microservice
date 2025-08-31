using System;
using System.IO.Ports;
using System.Threading;
using System.Threading.Tasks;

namespace FotoFinder.PolFlashXe.FlashViscaComHandler
{
    public class FlashViscaComHandler
    {
        public SerialPort ComPort { get; private set; }
        public bool IsConnected { get; set; }

        // contains the bytes received by the serial port
        // when an entire message is received the message
        // gets pushed to the receivedMessagesBuffer
        private ViscaDataBuffer receivedBytesBuffer = new ViscaDataBuffer(100);

        // contains the messages received by the serial port
        //private ViscaMessageBuffer receivedMessagesBuffer;

        // if different threads try to access the sending-methods at 
        // the same time they will "draw" tickets and "get in line"
        private SemaphoreSlim semaphoreSlim = new SemaphoreSlim(1, 1);

        public void Connect(string port)
        {
            ComPort = new SerialPort(port);
            ComPort.BaudRate = 9600;
            ComPort.Parity = Parity.None;
            ComPort.StopBits = StopBits.One;
            ComPort.DataBits = 8;
            ComPort.PortName = port;
            //ComPort.Open();
            ComPort.DataReceived += DataReceived;

            // optional: Timeouts setzen, um explizit kontrollieren zu können
            ComPort.ReadTimeout = 2000;
            ComPort.WriteTimeout = 2000;
            // ggf. Hardware-Lines aktivieren
            ComPort.DtrEnable = true;
            ComPort.RtsEnable = true;
            ComPort.Handshake = Handshake.None;
            ComPort.Open();
        }

        public void Disconnect()
        {
            if (ComPort.IsOpen)
            {
                ComPort.DiscardInBuffer();
                ComPort.DiscardOutBuffer();
                ComPort.DataReceived -= DataReceived;
                ComPort.Close();
            }                
        }

        public event EventHandler<byte[]> NotificationReceived = delegate { };

        private TaskCompletionSource<byte[]> ReplyReceived = null;

        private void DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            // push received bytes into the buffer and fire event once a complete comment has been received
            while (ComPort.IsOpen && ComPort.BytesToRead > 0)
            {
                byte newByte = (byte)ComPort.ReadByte();
                receivedBytesBuffer.Push(newByte);

                // is new byte end of an message?
                if (newByte == 0xFF)
                {
                    byte[] message = receivedBytesBuffer.GetContent();
                    receivedBytesBuffer.Reset();

                    // check if event or reply to an inquriy
                    if (message[0] == 0x30)
                    {
                        if (message[1] == 0x01 || message[1] == 0x09)   // Ack, Inquiry or Unknown
                        {
                            ReplyReceived?.TrySetResult(message);
                        }
                        else
                        {
                            NotificationReceived(null, message);
                        }
                    }
                }
            }
        }

        public void SendReceive(ViscaMessage message)
        {
            if(semaphoreSlim.Wait(ViscaSettings.QueueThreadTime))
            {
                try
                {
                    // send message
                    ComPort.Write(message.Command, 0, message.Command.Length);



                    // wait for ReplyReceived Event to fire
                    ReplyReceived = new TaskCompletionSource<byte[]>();

                    if (ReplyReceived.Task.Wait(100))
                    {
                        // Copy contents of reply message
                        message.Reply = new byte[ReplyReceived.Task.Result.Length];
                        Array.Copy(ReplyReceived.Task.Result, message.Reply, ReplyReceived.Task.Result.Length);
                    }
                    else
                    {
                        throw new ApplicationException("Send Message Timeout!");
                    }
                }
                finally
                {
                    semaphoreSlim.Release();
                }
                
            }
        }
    }
}
