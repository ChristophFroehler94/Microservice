using FotoFinder.PolFlashXE.FlashDevices.Settings;
using System;

namespace FotoFinder.PolFlashXE.FlashDevices
{
    public interface IFlashDevice2 : IFlashDevice
    {
        // Controll Flash
        void Trigger();

        // Device Settings
        void ResetFlashCount();
        int GetFlashCount();       
    }
}