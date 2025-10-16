using FotoFinder.PolFlashXE.FlashDevices;
using FotoFinder.PolFlashXE.FlashDevices.Settings;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;

namespace FotoFinder.PolFlashGrpc.Services
{
    /// <summary>
    /// gRPC-Implementierung für PolFlash-Steuerung (v1/v2), mit Business-Outcome-Metriken.
    /// </summary>
    public class FlashControlService : FlashControl.FlashControlBase
    {
        private readonly IFlashDevice _device;
        private readonly ILogger<FlashControlService> _logger;

        public FlashControlService(IFlashDevice device, ILogger<FlashControlService> logger)
        {
            _device = device;
            _logger = logger;
        }

        // ------------------------------------------------------------
        // Helpers
        // ------------------------------------------------------------
        private static bool TryGetV2(IFlashDevice dev, out IFlashDevice2 v2)
        {
            v2 = dev as IFlashDevice2 ?? null!;
            return v2 is not null;
        }

        private static void ValidatePercentage(double value, string name)
        {
            if (double.IsNaN(value) || value < 0.0 || value > 100.0)
                throw new RpcException(new Status(StatusCode.InvalidArgument, $"{name} must be in [0, 100]."));
        }

        // ------------------------------------------------------------
        // RPCs aus .proto
        // ------------------------------------------------------------

        public override Task<TaskResult> Charge(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("Charge() called by {Peer}", context.Peer);
            try
            {
                _device.Charge();
                _logger.LogInformation("Charge succeeded");
                global::PolTelemetry.RecordBusiness(context.Method, true);
                return Task.FromResult(new TaskResult { Success = true, Message = "Charged" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Charge failed");
                global::PolTelemetry.RecordBusiness(context.Method, false);
                return Task.FromResult(new TaskResult { Success = false, Message = ex.Message });
            }
        }

        public override Task<TaskResult> Discharge(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("Discharge() called by {Peer}", context.Peer);
            try
            {
                _device.Discharge();
                _logger.LogInformation("Discharge succeeded");
                global::PolTelemetry.RecordBusiness(context.Method, true);
                return Task.FromResult(new TaskResult { Success = true, Message = "Discharged" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Discharge failed");
                global::PolTelemetry.RecordBusiness(context.Method, false);
                return Task.FromResult(new TaskResult { Success = false, Message = ex.Message });
            }
        }

        public override Task<TaskResult> Trigger(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("Trigger() called by {Peer}", context.Peer);

            if (!TryGetV2(_device, out var v2))
            {
                // .proto kennt Trigger, deshalb klar signalisieren, wenn das Gerät/Driver es nicht kann.
                throw new RpcException(new Status(StatusCode.Unimplemented,
                    "Trigger is not supported by this device/driver (IFlashDevice2 required)."));
            }

            try
            {
                v2.Trigger();
                _logger.LogInformation("Trigger succeeded");
                global::PolTelemetry.RecordBusiness(context.Method, true);
                return Task.FromResult(new TaskResult { Success = true, Message = "Triggered" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Trigger failed");
                global::PolTelemetry.RecordBusiness(context.Method, false);
                return Task.FromResult(new TaskResult { Success = false, Message = ex.Message });
            }
        }

        public override Task<FlashStateResponse> GetFlashState(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetFlashState() called");
            var state = (int)_device.DeviceState;
            _logger.LogInformation("Current DeviceState: {State}", state);
            return Task.FromResult(new FlashStateResponse { State = state });
        }

        public override Task<GetFlashCountResponse> GetFlashCount(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetFlashCount() called by {Peer}", context.Peer);

            if (!TryGetV2(_device, out var v2))
            {
                throw new RpcException(new Status(StatusCode.Unimplemented,
                    "Flash count is not supported by this device/driver (IFlashDevice2 required)."));
            }

            try
            {
                var count = v2.GetFlashCount();
                _logger.LogInformation("FlashCount: {Count}", count);
                return Task.FromResult(new GetFlashCountResponse { Count = count });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetFlashCount failed");
                // Für reine Getter lieber Abbruch via gRPC-Fehler statt Success=false
                throw new RpcException(new Status(StatusCode.Internal, ex.Message));
            }
        }

        public override Task<TaskResult> SetFlashEnergy(SetFlashEnergyRequest request, ServerCallContext context)
        {
            _logger.LogInformation("SetFlashEnergy() called: Right={Right}, Left={Left}",
                request.PercentageRight, request.PercentageLeft);

            try
            {
                ValidatePercentage(request.PercentageRight, nameof(request.PercentageRight));
                ValidatePercentage(request.PercentageLeft, nameof(request.PercentageLeft));

                _device.SetFlashEnergy(request.PercentageRight, request.PercentageLeft);
                _logger.LogInformation("SetFlashEnergy succeeded");
                global::PolTelemetry.RecordBusiness(context.Method, true);
                return Task.FromResult(new TaskResult { Success = true, Message = "Energy set" });
            }
            catch (RpcException) { throw; }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SetFlashEnergy failed");
                global::PolTelemetry.RecordBusiness(context.Method, false);
                return Task.FromResult(new TaskResult { Success = false, Message = ex.Message });
            }
        }

        public override Task<TaskResult> SetPolarization(SetPolarizationRequest request, ServerCallContext context)
        {
            _logger.LogInformation("SetPolarization() called: RightMode={RightMode}, LeftMode={LeftMode}",
                request.RightMode, request.LeftMode);
            try
            {
                var right = request.RightMode == SetPolarizationRequest.Types.PolarizationMode.Polarized;
                var left = request.LeftMode == SetPolarizationRequest.Types.PolarizationMode.Polarized;

                _device.SetPolarization(
                    right ? PolarizationModes.polarized : PolarizationModes.unpolarized,
                    left ? PolarizationModes.polarized : PolarizationModes.unpolarized
                );

                _logger.LogInformation("SetPolarization succeeded");
                global::PolTelemetry.RecordBusiness(context.Method, true);
                return Task.FromResult(new TaskResult { Success = true, Message = "Polarization set" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SetPolarization failed");
                global::PolTelemetry.RecordBusiness(context.Method, false);
                return Task.FromResult(new TaskResult { Success = false, Message = ex.Message });
            }
        }

        public override Task<TaskResult> SetLaser(LaserRequest request, ServerCallContext context)
        {
            _logger.LogInformation("SetLaser() called: IsActive={IsActive}", request.IsActive);
            try
            {
                _device.SetLaser(request.IsActive);
                _logger.LogInformation("SetLaser succeeded");
                global::PolTelemetry.RecordBusiness(context.Method, true);
                return Task.FromResult(new TaskResult { Success = true, Message = "Laser set" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SetLaser failed");
                global::PolTelemetry.RecordBusiness(context.Method, false);
                return Task.FromResult(new TaskResult { Success = false, Message = ex.Message });
            }
        }

        public override Task<PolarizationModeResponse> GetPolarizationMode(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetPolarizationMode() called");
            _device.GetPolarizationMode();

            var right = _device.RightPolarizationMode == PolarizationModes.polarized
                ? SetPolarizationRequest.Types.PolarizationMode.Polarized
                : SetPolarizationRequest.Types.PolarizationMode.Unpolarized;

            var left = _device.LeftPolarizationMode == PolarizationModes.polarized
                ? SetPolarizationRequest.Types.PolarizationMode.Polarized
                : SetPolarizationRequest.Types.PolarizationMode.Unpolarized;

            _logger.LogInformation("Current Polarization: Right={Right}, Left={Left}", right, left);

            return Task.FromResult(new PolarizationModeResponse
            {
                RightMode = right,
                LeftMode = left
            });
        }

        public override Task<VersionResponse> GetSoftwareVersion(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetSoftwareVersion() called");
            _device.GetSoftwareVersion();
            var major = _device.SwVersion.Major;
            var minor = _device.SwVersion.Minor;
            _logger.LogInformation("Software Version: {Major}.{Minor}", major, minor);
            return Task.FromResult(new VersionResponse { Major = major, Minor = minor });
        }

        public override Task<VersionResponse> GetHardwareVersion(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetHardwareVersion() called");
            _device.GetHardwareVersion();
            var major = _device.HwVersion.Major;
            var minor = _device.HwVersion.Minor;
            _logger.LogInformation("Hardware Version: {Major}.{Minor}", major, minor);
            return Task.FromResult(new VersionResponse { Major = major, Minor = minor });
        }

        public override Task<FlashEnergyResponse> GetFlashEnergy(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetFlashEnergy() called");
            _device.GetFlashEnergy();
            _logger.LogInformation("Flash Energy: Right={Right}, Left={Left}",
                _device.FlashEnergyRight, _device.FlashEnergyLeft);

            return Task.FromResult(new FlashEnergyResponse
            {
                PercentageRight = _device.FlashEnergyRight,
                PercentageLeft = _device.FlashEnergyLeft
            });
        }

        public override Task<FlashStateResponse> GetStateMachine(Empty request, ServerCallContext context)
        {
            _logger.LogInformation("GetStateMachine() called");
            _device.GetStateMaschine();
            var state = (int)_device.DeviceState;
            _logger.LogInformation("StateMachine result: {State}", state);
            return Task.FromResult(new FlashStateResponse { State = state });
        }
    }
}
