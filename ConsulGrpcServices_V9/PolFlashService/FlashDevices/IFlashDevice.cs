using FotoFinder.PolFlashXE.FlashDevices.Settings;
using System;

namespace FotoFinder.PolFlashXE.FlashDevices
{
    public interface IFlashDevice
    {
        // Version
        Version HwVersion { get; }
        Version SwVersion { get; }

        // State Attributes
        bool IsInitialized { get; }
        FlashState DeviceState { get; }
        PolarizationModes LeftPolarizationMode { get; }
        PolarizationModes RightPolarizationMode { get; }
        double FlashEnergyLeft { get; }
        double FlashEnergyRight { get; }
        string ComPort { get; }

        // Events
        event EventHandler<FlashState> StateChanged;
        event EventHandler ReadyToFlash;
        event EventHandler Waiting;

        // Connection
        void Connect();
        void Disconnect();
        void Initialize();

        // Controll Flash
        void Charge();   
        void Discharge();
        void SetLaser(bool IsActive);

        // Device Settings
        void SetFlashEnergy(double PercentageRight, double PercentageLeft);      
        void SetPolarization(PolarizationModes RightMode, PolarizationModes LeftMode);

        // Synchronise Device Data
        bool GetVccp();
        void GetFlashEnergy();
        void GetHardwareVersion();
        void GetPolarizationMode();
        void GetSoftwareVersion();
        void GetStateMaschine();        
    }
}