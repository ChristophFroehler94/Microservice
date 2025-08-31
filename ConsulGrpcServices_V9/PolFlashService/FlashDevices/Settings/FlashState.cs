namespace FotoFinder.PolFlashXE.FlashDevices.Settings
{
    public enum FlashState : int
    {
        /// <summary>
        /// state maschin waits for charge command
        /// </summary>
        wait = 0,

        /// <summary>
        /// capacitors are charging
        /// </summary>
        charge = 1,

        /// <summary>
        /// capacitors are charged, ready for flash
        /// </summary>
        ready = 2,

        /// <summary>
        /// discharging capacitors
        /// </summary>
        discharge = 3,

        /// <summary>
        /// polflash is flashing, this state lasts for a few ms, 
        /// this mode only exists in firmware 0.2 upwards
        /// </summary>
        flashing = 4,

        /// <summary>
        /// no power available on tubes, this mode only exists in firmware 0.2 upwards
        /// </summary>
        standby = 5,
    }
}
