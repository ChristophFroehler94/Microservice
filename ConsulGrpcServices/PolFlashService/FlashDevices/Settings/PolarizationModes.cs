namespace FotoFinder.PolFlashXE.FlashDevices.Settings
{
    /// <summary>
    /// Polarization modes for SetPolarizationAsync function
    /// </summary>

    public enum PolarizationModes : int
    {
        /// <summary>
        /// Sets the state maschine to discharge
        /// </summary>
        unpolarized = 0,

        /// <summary>
        /// Sets the state maschine to charge
        /// </summary>
        polarized = 1,
    }
}
