// This is a generated file - do not edit.
//
// Generated from flashcontrol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'flashcontrol.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'flashcontrol.pbenum.dart';

class TaskResult extends $pb.GeneratedMessage {
  factory TaskResult({
    $core.bool? success,
    $core.String? message,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (message != null) result.message = message;
    return result;
  }

  TaskResult._();

  factory TaskResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TaskResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TaskResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TaskResult copyWith(void Function(TaskResult) updates) =>
      super.copyWith((message) => updates(message as TaskResult)) as TaskResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskResult create() => TaskResult._();
  @$core.override
  TaskResult createEmptyInstance() => create();
  static $pb.PbList<TaskResult> createRepeated() => $pb.PbList<TaskResult>();
  @$core.pragma('dart2js:noInline')
  static TaskResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TaskResult>(create);
  static TaskResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class FlashStateResponse extends $pb.GeneratedMessage {
  factory FlashStateResponse({
    $core.int? state,
  }) {
    final result = create();
    if (state != null) result.state = state;
    return result;
  }

  FlashStateResponse._();

  factory FlashStateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlashStateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlashStateResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'state')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashStateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashStateResponse copyWith(void Function(FlashStateResponse) updates) =>
      super.copyWith((message) => updates(message as FlashStateResponse))
          as FlashStateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashStateResponse create() => FlashStateResponse._();
  @$core.override
  FlashStateResponse createEmptyInstance() => create();
  static $pb.PbList<FlashStateResponse> createRepeated() =>
      $pb.PbList<FlashStateResponse>();
  @$core.pragma('dart2js:noInline')
  static FlashStateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlashStateResponse>(create);
  static FlashStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get state => $_getIZ(0);
  @$pb.TagNumber(1)
  set state($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);
}

class GetFlashCountResponse extends $pb.GeneratedMessage {
  factory GetFlashCountResponse({
    $core.int? count,
  }) {
    final result = create();
    if (count != null) result.count = count;
    return result;
  }

  GetFlashCountResponse._();

  factory GetFlashCountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFlashCountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFlashCountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlashCountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFlashCountResponse copyWith(
          void Function(GetFlashCountResponse) updates) =>
      super.copyWith((message) => updates(message as GetFlashCountResponse))
          as GetFlashCountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFlashCountResponse create() => GetFlashCountResponse._();
  @$core.override
  GetFlashCountResponse createEmptyInstance() => create();
  static $pb.PbList<GetFlashCountResponse> createRepeated() =>
      $pb.PbList<GetFlashCountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFlashCountResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFlashCountResponse>(create);
  static GetFlashCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get count => $_getIZ(0);
  @$pb.TagNumber(1)
  set count($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class SetFlashEnergyRequest extends $pb.GeneratedMessage {
  factory SetFlashEnergyRequest({
    $core.double? percentageRight,
    $core.double? percentageLeft,
  }) {
    final result = create();
    if (percentageRight != null) result.percentageRight = percentageRight;
    if (percentageLeft != null) result.percentageLeft = percentageLeft;
    return result;
  }

  SetFlashEnergyRequest._();

  factory SetFlashEnergyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFlashEnergyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFlashEnergyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'percentageRight',
        protoName: 'percentageRight')
    ..aD(2, _omitFieldNames ? '' : 'percentageLeft',
        protoName: 'percentageLeft')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFlashEnergyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFlashEnergyRequest copyWith(
          void Function(SetFlashEnergyRequest) updates) =>
      super.copyWith((message) => updates(message as SetFlashEnergyRequest))
          as SetFlashEnergyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFlashEnergyRequest create() => SetFlashEnergyRequest._();
  @$core.override
  SetFlashEnergyRequest createEmptyInstance() => create();
  static $pb.PbList<SetFlashEnergyRequest> createRepeated() =>
      $pb.PbList<SetFlashEnergyRequest>();
  @$core.pragma('dart2js:noInline')
  static SetFlashEnergyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFlashEnergyRequest>(create);
  static SetFlashEnergyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get percentageRight => $_getN(0);
  @$pb.TagNumber(1)
  set percentageRight($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPercentageRight() => $_has(0);
  @$pb.TagNumber(1)
  void clearPercentageRight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get percentageLeft => $_getN(1);
  @$pb.TagNumber(2)
  set percentageLeft($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPercentageLeft() => $_has(1);
  @$pb.TagNumber(2)
  void clearPercentageLeft() => $_clearField(2);
}

class SetPolarizationRequest extends $pb.GeneratedMessage {
  factory SetPolarizationRequest({
    SetPolarizationRequest_PolarizationMode? rightMode,
    SetPolarizationRequest_PolarizationMode? leftMode,
  }) {
    final result = create();
    if (rightMode != null) result.rightMode = rightMode;
    if (leftMode != null) result.leftMode = leftMode;
    return result;
  }

  SetPolarizationRequest._();

  factory SetPolarizationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPolarizationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetPolarizationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aE<SetPolarizationRequest_PolarizationMode>(
        1, _omitFieldNames ? '' : 'rightMode',
        protoName: 'rightMode',
        enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..aE<SetPolarizationRequest_PolarizationMode>(
        2, _omitFieldNames ? '' : 'leftMode',
        protoName: 'leftMode',
        enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPolarizationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPolarizationRequest copyWith(
          void Function(SetPolarizationRequest) updates) =>
      super.copyWith((message) => updates(message as SetPolarizationRequest))
          as SetPolarizationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPolarizationRequest create() => SetPolarizationRequest._();
  @$core.override
  SetPolarizationRequest createEmptyInstance() => create();
  static $pb.PbList<SetPolarizationRequest> createRepeated() =>
      $pb.PbList<SetPolarizationRequest>();
  @$core.pragma('dart2js:noInline')
  static SetPolarizationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetPolarizationRequest>(create);
  static SetPolarizationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SetPolarizationRequest_PolarizationMode get rightMode => $_getN(0);
  @$pb.TagNumber(1)
  set rightMode(SetPolarizationRequest_PolarizationMode value) =>
      $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRightMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRightMode() => $_clearField(1);

  @$pb.TagNumber(2)
  SetPolarizationRequest_PolarizationMode get leftMode => $_getN(1);
  @$pb.TagNumber(2)
  set leftMode(SetPolarizationRequest_PolarizationMode value) =>
      $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLeftMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeftMode() => $_clearField(2);
}

class LaserRequest extends $pb.GeneratedMessage {
  factory LaserRequest({
    $core.bool? isActive,
  }) {
    final result = create();
    if (isActive != null) result.isActive = isActive;
    return result;
  }

  LaserRequest._();

  factory LaserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LaserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LaserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isActive', protoName: 'isActive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LaserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LaserRequest copyWith(void Function(LaserRequest) updates) =>
      super.copyWith((message) => updates(message as LaserRequest))
          as LaserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LaserRequest create() => LaserRequest._();
  @$core.override
  LaserRequest createEmptyInstance() => create();
  static $pb.PbList<LaserRequest> createRepeated() =>
      $pb.PbList<LaserRequest>();
  @$core.pragma('dart2js:noInline')
  static LaserRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LaserRequest>(create);
  static LaserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isActive => $_getBF(0);
  @$pb.TagNumber(1)
  set isActive($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsActive() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsActive() => $_clearField(1);
}

class PolarizationModeResponse extends $pb.GeneratedMessage {
  factory PolarizationModeResponse({
    SetPolarizationRequest_PolarizationMode? rightMode,
    SetPolarizationRequest_PolarizationMode? leftMode,
  }) {
    final result = create();
    if (rightMode != null) result.rightMode = rightMode;
    if (leftMode != null) result.leftMode = leftMode;
    return result;
  }

  PolarizationModeResponse._();

  factory PolarizationModeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PolarizationModeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PolarizationModeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aE<SetPolarizationRequest_PolarizationMode>(
        1, _omitFieldNames ? '' : 'rightMode',
        protoName: 'rightMode',
        enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..aE<SetPolarizationRequest_PolarizationMode>(
        2, _omitFieldNames ? '' : 'leftMode',
        protoName: 'leftMode',
        enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolarizationModeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PolarizationModeResponse copyWith(
          void Function(PolarizationModeResponse) updates) =>
      super.copyWith((message) => updates(message as PolarizationModeResponse))
          as PolarizationModeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolarizationModeResponse create() => PolarizationModeResponse._();
  @$core.override
  PolarizationModeResponse createEmptyInstance() => create();
  static $pb.PbList<PolarizationModeResponse> createRepeated() =>
      $pb.PbList<PolarizationModeResponse>();
  @$core.pragma('dart2js:noInline')
  static PolarizationModeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PolarizationModeResponse>(create);
  static PolarizationModeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SetPolarizationRequest_PolarizationMode get rightMode => $_getN(0);
  @$pb.TagNumber(1)
  set rightMode(SetPolarizationRequest_PolarizationMode value) =>
      $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRightMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRightMode() => $_clearField(1);

  @$pb.TagNumber(2)
  SetPolarizationRequest_PolarizationMode get leftMode => $_getN(1);
  @$pb.TagNumber(2)
  set leftMode(SetPolarizationRequest_PolarizationMode value) =>
      $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLeftMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeftMode() => $_clearField(2);
}

class VersionResponse extends $pb.GeneratedMessage {
  factory VersionResponse({
    $core.int? major,
    $core.int? minor,
  }) {
    final result = create();
    if (major != null) result.major = major;
    if (minor != null) result.minor = minor;
    return result;
  }

  VersionResponse._();

  factory VersionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VersionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VersionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'major')
    ..aI(2, _omitFieldNames ? '' : 'minor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VersionResponse copyWith(void Function(VersionResponse) updates) =>
      super.copyWith((message) => updates(message as VersionResponse))
          as VersionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionResponse create() => VersionResponse._();
  @$core.override
  VersionResponse createEmptyInstance() => create();
  static $pb.PbList<VersionResponse> createRepeated() =>
      $pb.PbList<VersionResponse>();
  @$core.pragma('dart2js:noInline')
  static VersionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VersionResponse>(create);
  static VersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get major => $_getIZ(0);
  @$pb.TagNumber(1)
  set major($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMajor() => $_has(0);
  @$pb.TagNumber(1)
  void clearMajor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minor => $_getIZ(1);
  @$pb.TagNumber(2)
  set minor($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinor() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinor() => $_clearField(2);
}

class FlashEnergyResponse extends $pb.GeneratedMessage {
  factory FlashEnergyResponse({
    $core.double? percentageRight,
    $core.double? percentageLeft,
  }) {
    final result = create();
    if (percentageRight != null) result.percentageRight = percentageRight;
    if (percentageLeft != null) result.percentageLeft = percentageLeft;
    return result;
  }

  FlashEnergyResponse._();

  factory FlashEnergyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FlashEnergyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FlashEnergyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'percentageRight',
        protoName: 'percentageRight')
    ..aD(2, _omitFieldNames ? '' : 'percentageLeft',
        protoName: 'percentageLeft')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashEnergyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FlashEnergyResponse copyWith(void Function(FlashEnergyResponse) updates) =>
      super.copyWith((message) => updates(message as FlashEnergyResponse))
          as FlashEnergyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashEnergyResponse create() => FlashEnergyResponse._();
  @$core.override
  FlashEnergyResponse createEmptyInstance() => create();
  static $pb.PbList<FlashEnergyResponse> createRepeated() =>
      $pb.PbList<FlashEnergyResponse>();
  @$core.pragma('dart2js:noInline')
  static FlashEnergyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FlashEnergyResponse>(create);
  static FlashEnergyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get percentageRight => $_getN(0);
  @$pb.TagNumber(1)
  set percentageRight($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPercentageRight() => $_has(0);
  @$pb.TagNumber(1)
  void clearPercentageRight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get percentageLeft => $_getN(1);
  @$pb.TagNumber(2)
  set percentageLeft($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPercentageLeft() => $_has(1);
  @$pb.TagNumber(2)
  void clearPercentageLeft() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
