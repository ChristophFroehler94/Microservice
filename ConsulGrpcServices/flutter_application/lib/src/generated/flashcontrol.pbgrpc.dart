// This is a generated file - do not edit.
//
// Generated from flashcontrol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'flashcontrol.pb.dart' as $1;
import 'google/protobuf/empty.pb.dart' as $0;

export 'flashcontrol.pb.dart';

@$pb.GrpcServiceName('polflash.FlashControl')
class FlashControlClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  FlashControlClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$1.TaskResult> charge(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$charge, request, options: options);
  }

  $grpc.ResponseFuture<$1.TaskResult> discharge(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$discharge, request, options: options);
  }

  $grpc.ResponseFuture<$1.TaskResult> trigger(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$trigger, request, options: options);
  }

  $grpc.ResponseFuture<$1.FlashStateResponse> getFlashState(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFlashState, request, options: options);
  }

  $grpc.ResponseFuture<$1.GetFlashCountResponse> getFlashCount(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFlashCount, request, options: options);
  }

  $grpc.ResponseFuture<$1.TaskResult> setFlashEnergy(
    $1.SetFlashEnergyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setFlashEnergy, request, options: options);
  }

  $grpc.ResponseFuture<$1.TaskResult> setPolarization(
    $1.SetPolarizationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPolarization, request, options: options);
  }

  $grpc.ResponseFuture<$1.TaskResult> setLaser(
    $1.LaserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setLaser, request, options: options);
  }

  $grpc.ResponseFuture<$1.PolarizationModeResponse> getPolarizationMode(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPolarizationMode, request, options: options);
  }

  $grpc.ResponseFuture<$1.VersionResponse> getSoftwareVersion(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSoftwareVersion, request, options: options);
  }

  $grpc.ResponseFuture<$1.VersionResponse> getHardwareVersion(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getHardwareVersion, request, options: options);
  }

  $grpc.ResponseFuture<$1.FlashEnergyResponse> getFlashEnergy(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFlashEnergy, request, options: options);
  }

  $grpc.ResponseFuture<$1.FlashStateResponse> getStateMachine(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getStateMachine, request, options: options);
  }

  // method descriptors

  static final _$charge = $grpc.ClientMethod<$0.Empty, $1.TaskResult>(
      '/polflash.FlashControl/Charge',
      ($0.Empty value) => value.writeToBuffer(),
      $1.TaskResult.fromBuffer);
  static final _$discharge = $grpc.ClientMethod<$0.Empty, $1.TaskResult>(
      '/polflash.FlashControl/Discharge',
      ($0.Empty value) => value.writeToBuffer(),
      $1.TaskResult.fromBuffer);
  static final _$trigger = $grpc.ClientMethod<$0.Empty, $1.TaskResult>(
      '/polflash.FlashControl/Trigger',
      ($0.Empty value) => value.writeToBuffer(),
      $1.TaskResult.fromBuffer);
  static final _$getFlashState =
      $grpc.ClientMethod<$0.Empty, $1.FlashStateResponse>(
          '/polflash.FlashControl/GetFlashState',
          ($0.Empty value) => value.writeToBuffer(),
          $1.FlashStateResponse.fromBuffer);
  static final _$getFlashCount =
      $grpc.ClientMethod<$0.Empty, $1.GetFlashCountResponse>(
          '/polflash.FlashControl/GetFlashCount',
          ($0.Empty value) => value.writeToBuffer(),
          $1.GetFlashCountResponse.fromBuffer);
  static final _$setFlashEnergy =
      $grpc.ClientMethod<$1.SetFlashEnergyRequest, $1.TaskResult>(
          '/polflash.FlashControl/SetFlashEnergy',
          ($1.SetFlashEnergyRequest value) => value.writeToBuffer(),
          $1.TaskResult.fromBuffer);
  static final _$setPolarization =
      $grpc.ClientMethod<$1.SetPolarizationRequest, $1.TaskResult>(
          '/polflash.FlashControl/SetPolarization',
          ($1.SetPolarizationRequest value) => value.writeToBuffer(),
          $1.TaskResult.fromBuffer);
  static final _$setLaser = $grpc.ClientMethod<$1.LaserRequest, $1.TaskResult>(
      '/polflash.FlashControl/SetLaser',
      ($1.LaserRequest value) => value.writeToBuffer(),
      $1.TaskResult.fromBuffer);
  static final _$getPolarizationMode =
      $grpc.ClientMethod<$0.Empty, $1.PolarizationModeResponse>(
          '/polflash.FlashControl/GetPolarizationMode',
          ($0.Empty value) => value.writeToBuffer(),
          $1.PolarizationModeResponse.fromBuffer);
  static final _$getSoftwareVersion =
      $grpc.ClientMethod<$0.Empty, $1.VersionResponse>(
          '/polflash.FlashControl/GetSoftwareVersion',
          ($0.Empty value) => value.writeToBuffer(),
          $1.VersionResponse.fromBuffer);
  static final _$getHardwareVersion =
      $grpc.ClientMethod<$0.Empty, $1.VersionResponse>(
          '/polflash.FlashControl/GetHardwareVersion',
          ($0.Empty value) => value.writeToBuffer(),
          $1.VersionResponse.fromBuffer);
  static final _$getFlashEnergy =
      $grpc.ClientMethod<$0.Empty, $1.FlashEnergyResponse>(
          '/polflash.FlashControl/GetFlashEnergy',
          ($0.Empty value) => value.writeToBuffer(),
          $1.FlashEnergyResponse.fromBuffer);
  static final _$getStateMachine =
      $grpc.ClientMethod<$0.Empty, $1.FlashStateResponse>(
          '/polflash.FlashControl/GetStateMachine',
          ($0.Empty value) => value.writeToBuffer(),
          $1.FlashStateResponse.fromBuffer);
}

@$pb.GrpcServiceName('polflash.FlashControl')
abstract class FlashControlServiceBase extends $grpc.Service {
  $core.String get $name => 'polflash.FlashControl';

  FlashControlServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.TaskResult>(
        'Charge',
        charge_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.TaskResult>(
        'Discharge',
        discharge_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.TaskResult>(
        'Trigger',
        trigger_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.FlashStateResponse>(
        'GetFlashState',
        getFlashState_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.FlashStateResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.GetFlashCountResponse>(
        'GetFlashCount',
        getFlashCount_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.GetFlashCountResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SetFlashEnergyRequest, $1.TaskResult>(
        'SetFlashEnergy',
        setFlashEnergy_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.SetFlashEnergyRequest.fromBuffer(value),
        ($1.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.SetPolarizationRequest, $1.TaskResult>(
        'SetPolarization',
        setPolarization_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $1.SetPolarizationRequest.fromBuffer(value),
        ($1.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.LaserRequest, $1.TaskResult>(
        'SetLaser',
        setLaser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.LaserRequest.fromBuffer(value),
        ($1.TaskResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.PolarizationModeResponse>(
        'GetPolarizationMode',
        getPolarizationMode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.PolarizationModeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.VersionResponse>(
        'GetSoftwareVersion',
        getSoftwareVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.VersionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.VersionResponse>(
        'GetHardwareVersion',
        getHardwareVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.VersionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.FlashEnergyResponse>(
        'GetFlashEnergy',
        getFlashEnergy_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.FlashEnergyResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $1.FlashStateResponse>(
        'GetStateMachine',
        getStateMachine_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($1.FlashStateResponse value) => value.writeToBuffer()));
  }

  $async.Future<$1.TaskResult> charge_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return charge($call, await $request);
  }

  $async.Future<$1.TaskResult> charge($grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.TaskResult> discharge_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return discharge($call, await $request);
  }

  $async.Future<$1.TaskResult> discharge(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.TaskResult> trigger_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return trigger($call, await $request);
  }

  $async.Future<$1.TaskResult> trigger(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.FlashStateResponse> getFlashState_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getFlashState($call, await $request);
  }

  $async.Future<$1.FlashStateResponse> getFlashState(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.GetFlashCountResponse> getFlashCount_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getFlashCount($call, await $request);
  }

  $async.Future<$1.GetFlashCountResponse> getFlashCount(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.TaskResult> setFlashEnergy_Pre($grpc.ServiceCall $call,
      $async.Future<$1.SetFlashEnergyRequest> $request) async {
    return setFlashEnergy($call, await $request);
  }

  $async.Future<$1.TaskResult> setFlashEnergy(
      $grpc.ServiceCall call, $1.SetFlashEnergyRequest request);

  $async.Future<$1.TaskResult> setPolarization_Pre($grpc.ServiceCall $call,
      $async.Future<$1.SetPolarizationRequest> $request) async {
    return setPolarization($call, await $request);
  }

  $async.Future<$1.TaskResult> setPolarization(
      $grpc.ServiceCall call, $1.SetPolarizationRequest request);

  $async.Future<$1.TaskResult> setLaser_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.LaserRequest> $request) async {
    return setLaser($call, await $request);
  }

  $async.Future<$1.TaskResult> setLaser(
      $grpc.ServiceCall call, $1.LaserRequest request);

  $async.Future<$1.PolarizationModeResponse> getPolarizationMode_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getPolarizationMode($call, await $request);
  }

  $async.Future<$1.PolarizationModeResponse> getPolarizationMode(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.VersionResponse> getSoftwareVersion_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getSoftwareVersion($call, await $request);
  }

  $async.Future<$1.VersionResponse> getSoftwareVersion(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.VersionResponse> getHardwareVersion_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getHardwareVersion($call, await $request);
  }

  $async.Future<$1.VersionResponse> getHardwareVersion(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.FlashEnergyResponse> getFlashEnergy_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getFlashEnergy($call, await $request);
  }

  $async.Future<$1.FlashEnergyResponse> getFlashEnergy(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$1.FlashStateResponse> getStateMachine_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getStateMachine($call, await $request);
  }

  $async.Future<$1.FlashStateResponse> getStateMachine(
      $grpc.ServiceCall call, $0.Empty request);
}
