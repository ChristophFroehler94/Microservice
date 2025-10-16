//
//  Generated code. Do not modify.
//  source: flashcontrol.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'flashcontrol.pb.dart' as $2;
import 'google/protobuf/empty.pb.dart' as $1;

export 'flashcontrol.pb.dart';

@$pb.GrpcServiceName('polflash.FlashControl')
class FlashControlClient extends $grpc.Client {
  static final _$charge = $grpc.ClientMethod<$1.Empty, $2.TaskResult>(
      '/polflash.FlashControl/Charge',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.TaskResult.fromBuffer(value));
  static final _$discharge = $grpc.ClientMethod<$1.Empty, $2.TaskResult>(
      '/polflash.FlashControl/Discharge',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.TaskResult.fromBuffer(value));
  static final _$trigger = $grpc.ClientMethod<$1.Empty, $2.TaskResult>(
      '/polflash.FlashControl/Trigger',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.TaskResult.fromBuffer(value));
  static final _$getFlashState = $grpc.ClientMethod<$1.Empty, $2.FlashStateResponse>(
      '/polflash.FlashControl/GetFlashState',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.FlashStateResponse.fromBuffer(value));
  static final _$getFlashCount = $grpc.ClientMethod<$1.Empty, $2.GetFlashCountResponse>(
      '/polflash.FlashControl/GetFlashCount',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.GetFlashCountResponse.fromBuffer(value));
  static final _$setFlashEnergy = $grpc.ClientMethod<$2.SetFlashEnergyRequest, $2.TaskResult>(
      '/polflash.FlashControl/SetFlashEnergy',
      ($2.SetFlashEnergyRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.TaskResult.fromBuffer(value));
  static final _$setPolarization = $grpc.ClientMethod<$2.SetPolarizationRequest, $2.TaskResult>(
      '/polflash.FlashControl/SetPolarization',
      ($2.SetPolarizationRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.TaskResult.fromBuffer(value));
  static final _$setLaser = $grpc.ClientMethod<$2.LaserRequest, $2.TaskResult>(
      '/polflash.FlashControl/SetLaser',
      ($2.LaserRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.TaskResult.fromBuffer(value));
  static final _$getPolarizationMode = $grpc.ClientMethod<$1.Empty, $2.PolarizationModeResponse>(
      '/polflash.FlashControl/GetPolarizationMode',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.PolarizationModeResponse.fromBuffer(value));
  static final _$getSoftwareVersion = $grpc.ClientMethod<$1.Empty, $2.VersionResponse>(
      '/polflash.FlashControl/GetSoftwareVersion',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.VersionResponse.fromBuffer(value));
  static final _$getHardwareVersion = $grpc.ClientMethod<$1.Empty, $2.VersionResponse>(
      '/polflash.FlashControl/GetHardwareVersion',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.VersionResponse.fromBuffer(value));
  static final _$getFlashEnergy = $grpc.ClientMethod<$1.Empty, $2.FlashEnergyResponse>(
      '/polflash.FlashControl/GetFlashEnergy',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.FlashEnergyResponse.fromBuffer(value));
  static final _$getStateMachine = $grpc.ClientMethod<$1.Empty, $2.FlashStateResponse>(
      '/polflash.FlashControl/GetStateMachine',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.FlashStateResponse.fromBuffer(value));

  FlashControlClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$2.TaskResult> charge($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$charge, request, options: options);
  }

  $grpc.ResponseFuture<$2.TaskResult> discharge($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$discharge, request, options: options);
  }

  $grpc.ResponseFuture<$2.TaskResult> trigger($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$trigger, request, options: options);
  }

  $grpc.ResponseFuture<$2.FlashStateResponse> getFlashState($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getFlashState, request, options: options);
  }

  $grpc.ResponseFuture<$2.GetFlashCountResponse> getFlashCount($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getFlashCount, request, options: options);
  }

  $grpc.ResponseFuture<$2.TaskResult> setFlashEnergy($2.SetFlashEnergyRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setFlashEnergy, request, options: options);
  }

  $grpc.ResponseFuture<$2.TaskResult> setPolarization($2.SetPolarizationRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setPolarization, request, options: options);
  }

  $grpc.ResponseFuture<$2.TaskResult> setLaser($2.LaserRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setLaser, request, options: options);
  }

  $grpc.ResponseFuture<$2.PolarizationModeResponse> getPolarizationMode($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getPolarizationMode, request, options: options);
  }

  $grpc.ResponseFuture<$2.VersionResponse> getSoftwareVersion($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getSoftwareVersion, request, options: options);
  }

  $grpc.ResponseFuture<$2.VersionResponse> getHardwareVersion($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getHardwareVersion, request, options: options);
  }

  $grpc.ResponseFuture<$2.FlashEnergyResponse> getFlashEnergy($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getFlashEnergy, request, options: options);
  }

  $grpc.ResponseFuture<$2.FlashStateResponse> getStateMachine($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getStateMachine, request, options: options);
  }
}

@$pb.GrpcServiceName('polflash.FlashControl')
abstract class FlashControlServiceBase extends $grpc.Service {
  $core.String get $name => 'polflash.FlashControl';

  FlashControlServiceBase() {
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.TaskResult>(
        'Charge',
        charge_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.TaskResult>(
        'Discharge',
        discharge_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.TaskResult>(
        'Trigger',
        trigger_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.FlashStateResponse>(
        'GetFlashState',
        getFlashState_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.FlashStateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.GetFlashCountResponse>(
        'GetFlashCount',
        getFlashCount_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.GetFlashCountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.SetFlashEnergyRequest, $2.TaskResult>(
        'SetFlashEnergy',
        setFlashEnergy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.SetFlashEnergyRequest.fromBuffer(value),
        ($2.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.SetPolarizationRequest, $2.TaskResult>(
        'SetPolarization',
        setPolarization_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.SetPolarizationRequest.fromBuffer(value),
        ($2.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$2.LaserRequest, $2.TaskResult>(
        'SetLaser',
        setLaser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $2.LaserRequest.fromBuffer(value),
        ($2.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.PolarizationModeResponse>(
        'GetPolarizationMode',
        getPolarizationMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.PolarizationModeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.VersionResponse>(
        'GetSoftwareVersion',
        getSoftwareVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.VersionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.VersionResponse>(
        'GetHardwareVersion',
        getHardwareVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.VersionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.FlashEnergyResponse>(
        'GetFlashEnergy',
        getFlashEnergy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.FlashEnergyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.FlashStateResponse>(
        'GetStateMachine',
        getStateMachine_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.FlashStateResponse value) => value.writeToBuffer()));
  }

  $async.Future<$2.TaskResult> charge_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return charge($call, await $request);
  }

  $async.Future<$2.TaskResult> discharge_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return discharge($call, await $request);
  }

  $async.Future<$2.TaskResult> trigger_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return trigger($call, await $request);
  }

  $async.Future<$2.FlashStateResponse> getFlashState_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getFlashState($call, await $request);
  }

  $async.Future<$2.GetFlashCountResponse> getFlashCount_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getFlashCount($call, await $request);
  }

  $async.Future<$2.TaskResult> setFlashEnergy_Pre($grpc.ServiceCall $call, $async.Future<$2.SetFlashEnergyRequest> $request) async {
    return setFlashEnergy($call, await $request);
  }

  $async.Future<$2.TaskResult> setPolarization_Pre($grpc.ServiceCall $call, $async.Future<$2.SetPolarizationRequest> $request) async {
    return setPolarization($call, await $request);
  }

  $async.Future<$2.TaskResult> setLaser_Pre($grpc.ServiceCall $call, $async.Future<$2.LaserRequest> $request) async {
    return setLaser($call, await $request);
  }

  $async.Future<$2.PolarizationModeResponse> getPolarizationMode_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPolarizationMode($call, await $request);
  }

  $async.Future<$2.VersionResponse> getSoftwareVersion_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getSoftwareVersion($call, await $request);
  }

  $async.Future<$2.VersionResponse> getHardwareVersion_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getHardwareVersion($call, await $request);
  }

  $async.Future<$2.FlashEnergyResponse> getFlashEnergy_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getFlashEnergy($call, await $request);
  }

  $async.Future<$2.FlashStateResponse> getStateMachine_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getStateMachine($call, await $request);
  }

  $async.Future<$2.TaskResult> charge($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.TaskResult> discharge($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.TaskResult> trigger($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.FlashStateResponse> getFlashState($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.GetFlashCountResponse> getFlashCount($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.TaskResult> setFlashEnergy($grpc.ServiceCall call, $2.SetFlashEnergyRequest request);
  $async.Future<$2.TaskResult> setPolarization($grpc.ServiceCall call, $2.SetPolarizationRequest request);
  $async.Future<$2.TaskResult> setLaser($grpc.ServiceCall call, $2.LaserRequest request);
  $async.Future<$2.PolarizationModeResponse> getPolarizationMode($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.VersionResponse> getSoftwareVersion($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.VersionResponse> getHardwareVersion($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.FlashEnergyResponse> getFlashEnergy($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.FlashStateResponse> getStateMachine($grpc.ServiceCall call, $1.Empty request);
}
