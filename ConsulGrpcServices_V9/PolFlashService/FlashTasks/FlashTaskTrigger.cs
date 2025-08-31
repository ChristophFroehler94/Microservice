using FotoFinder.PolFlashXE.FlashDevices;
using FotoFinder.PolFlashXE.FlashDevices.Settings;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FotoFinder.PolFlashXE.FlashTasks
{
    public class FlashTaskTrigger : IFlashTask
    {
        private TaskCompletionSource<bool> _taskCompleted = null;
        private IFlashDevice2 flashDevice;
        private TimeSpan defaultTimeout = new TimeSpan(0, 0, 0, 0, 500);
        public string Name { get; } = "Trigger Flash";

        public async Task ExecuteAsync(TimeSpan TimeOut)
        {
            AssertStartCondition();
            await ResolveTask(TimeOut);
        }

        public FlashTaskTrigger(IFlashDevice2 flashDevice)
        {
            AssertDevice(flashDevice);        
        }

        private void FlashingDone(object sender, EventArgs e)
        {
            // Task done, signal to
            _taskCompleted?.TrySetResult(true);
        }

        private void AssertStartCondition()
        {
            if(flashDevice.IsInitialized && flashDevice.DeviceState == FlashState.ready)
            {
                return;
            }

            throw new ApplicationException($"Startcondition for Task {this.Name} not met!");
        }

        private void AssertDevice(IFlashDevice2 flashDevice)
        {
            if (flashDevice is PolFlashXeV2)
            {
                this.flashDevice = flashDevice; return;
            };

            throw new ApplicationException($"Task {this.Name} is not supported by {flashDevice.GetType()}");
        }       

        private async Task ResolveTask(TimeSpan TimeOut)
        {
            // Setup completion source
            _taskCompleted = new TaskCompletionSource<bool>();

            flashDevice.Trigger();
            flashDevice.Waiting += FlashingDone;

            // await done event or timeout
            await Task.WhenAny(_taskCompleted.Task, Task.Delay(TimeOut));

            if (_taskCompleted.Task.IsCompleted == false)
            {
                // fire timeout event
                throw new TimeoutException($"Task {this.Name} timed out");
            }
        }
    }
}
