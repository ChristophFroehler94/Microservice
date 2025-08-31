namespace FotoFinder.PolFlashXE.FlashTasks
{
    public class FlashTaskError
    {
        public bool IsSuccess { get; set; }
        public string ErrorMessage { get; set; }
        public FlashTaskErrorType Type { get; set; }
    }

    public enum FlashTaskErrorType : int
    {
        Done,
        StartConditionError,
        ExecutionError,
        TimeoutError
    }
}
