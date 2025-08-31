using System;
using System.Threading.Tasks;

using FotoFinder.PolFlashXE.FlashDevices;
using FotoFinder.PolFlashXE.FlashDevices.Settings;

namespace FotoFinder.PolFlashXE.FlashTasks
{
    public class FlashTaskCharge : IFlashTask
    {
        private TaskCompletionSource<bool> _taskCompleted = null;
        private IFlashDevice flashDevice;
        private TimeSpan _timeOut = new TimeSpan(0,0,0,0,2000);

        public string Name { get; private set; } = "Charge PolFlash";

        // constructor
        public FlashTaskCharge(IFlashDevice device)
        {
            AssertDevice(device);
        }

        public async Task ExecuteAsync(TimeSpan TimeOut)
        {
            AssertStartCondition();
            await ResolveTask(TimeOut);
        }

        private void AssertDevice(IFlashDevice flashDevice)
        {
            if (flashDevice == null)
            {
                throw new ArgumentNullException(nameof(flashDevice));
            }

            if (flashDevice is PolFlashXeV2)
            {
                this.flashDevice = flashDevice; return;
            };

            throw new ApplicationException($"Task {this.Name} is not supported by {flashDevice.GetType()}");
        }

        private void AssertStartCondition()
        {
            if (flashDevice != null && 
                flashDevice.IsInitialized && 
                flashDevice.DeviceState == FlashState.wait)
            {
                return;
            }

            throw new ApplicationException($"Startcondition for Task {this.Name} not met!");
        }

        public async Task ResolveTask(TimeSpan TimeOut)
        {
            AssertStartCondition();
            
            // Setup completion source
            _taskCompleted = new TaskCompletionSource<bool>();

            // send charge command
            flashDevice.Charge();
                
            // subscribe to IsReady Event
            flashDevice.ReadyToFlash += FlashDeviceReadyToFlash;

            // await done event or timeout
            await Task.WhenAny(_taskCompleted.Task, Task.Delay(_timeOut));

            if (_taskCompleted.Task.IsCompleted == false)
            {
                // fire is complete event
                throw new TimeoutException($"Task {this.Name} timed out");
            }           
        }

        private void FlashDeviceReadyToFlash(object sender, EventArgs e)
        {
            // Task done, signal to
            _taskCompleted?.TrySetResult(true);
        }
    }
}
