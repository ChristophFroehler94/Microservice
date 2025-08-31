using System;
using System.Threading.Tasks;

namespace FotoFinder.PolFlashXE.FlashTasks
{
    public interface IFlashTask
    {
        string Name { get; }

        // execute task
        Task ExecuteAsync(TimeSpan TimeOut);
    }
}
