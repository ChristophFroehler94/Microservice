//
//  Generated code. Do not modify.
//  source: flashcontrol.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

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
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  TaskResult._() : super();
  factory TaskResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TaskResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TaskResult', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TaskResult clone() => TaskResult()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TaskResult copyWith(void Function(TaskResult) updates) => super.copyWith((message) => updates(message as TaskResult)) as TaskResult;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TaskResult create() => TaskResult._();
  TaskResult createEmptyInstance() => create();
  static $pb.PbList<TaskResult> createRepeated() => $pb.PbList<TaskResult>();
  @$core.pragma('dart2js:noInline')
  static TaskResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TaskResult>(create);
  static TaskResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class FlashStateResponse extends $pb.GeneratedMessage {
  factory FlashStateResponse({
    $core.int? state,
  }) {
    final $result = create();
    if (state != null) {
      $result.state = state;
    }
    return $result;
  }
  FlashStateResponse._() : super();
  factory FlashStateResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FlashStateResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FlashStateResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'state', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FlashStateResponse clone() => FlashStateResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FlashStateResponse copyWith(void Function(FlashStateResponse) updates) => super.copyWith((message) => updates(message as FlashStateResponse)) as FlashStateResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashStateResponse create() => FlashStateResponse._();
  FlashStateResponse createEmptyInstance() => create();
  static $pb.PbList<FlashStateResponse> createRepeated() => $pb.PbList<FlashStateResponse>();
  @$core.pragma('dart2js:noInline')
  static FlashStateResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FlashStateResponse>(create);
  static FlashStateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get state => $_getIZ(0);
  @$pb.TagNumber(1)
  set state($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);
}

class GetFlashCountResponse extends $pb.GeneratedMessage {
  factory GetFlashCountResponse({
    $core.int? count,
  }) {
    final $result = create();
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  GetFlashCountResponse._() : super();
  factory GetFlashCountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFlashCountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFlashCountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'count', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFlashCountResponse clone() => GetFlashCountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFlashCountResponse copyWith(void Function(GetFlashCountResponse) updates) => super.copyWith((message) => updates(message as GetFlashCountResponse)) as GetFlashCountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFlashCountResponse create() => GetFlashCountResponse._();
  GetFlashCountResponse createEmptyInstance() => create();
  static $pb.PbList<GetFlashCountResponse> createRepeated() => $pb.PbList<GetFlashCountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFlashCountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFlashCountResponse>(create);
  static GetFlashCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get count => $_getIZ(0);
  @$pb.TagNumber(1)
  set count($core.int v) { $_setSignedInt32(0, v); }
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
    final $result = create();
    if (percentageRight != null) {
      $result.percentageRight = percentageRight;
    }
    if (percentageLeft != null) {
      $result.percentageLeft = percentageLeft;
    }
    return $result;
  }
  SetFlashEnergyRequest._() : super();
  factory SetFlashEnergyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetFlashEnergyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetFlashEnergyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'percentageRight', $pb.PbFieldType.OD, protoName: 'percentageRight')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'percentageLeft', $pb.PbFieldType.OD, protoName: 'percentageLeft')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetFlashEnergyRequest clone() => SetFlashEnergyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetFlashEnergyRequest copyWith(void Function(SetFlashEnergyRequest) updates) => super.copyWith((message) => updates(message as SetFlashEnergyRequest)) as SetFlashEnergyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFlashEnergyRequest create() => SetFlashEnergyRequest._();
  SetFlashEnergyRequest createEmptyInstance() => create();
  static $pb.PbList<SetFlashEnergyRequest> createRepeated() => $pb.PbList<SetFlashEnergyRequest>();
  @$core.pragma('dart2js:noInline')
  static SetFlashEnergyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetFlashEnergyRequest>(create);
  static SetFlashEnergyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get percentageRight => $_getN(0);
  @$pb.TagNumber(1)
  set percentageRight($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPercentageRight() => $_has(0);
  @$pb.TagNumber(1)
  void clearPercentageRight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get percentageLeft => $_getN(1);
  @$pb.TagNumber(2)
  set percentageLeft($core.double v) { $_setDouble(1, v); }
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
    final $result = create();
    if (rightMode != null) {
      $result.rightMode = rightMode;
    }
    if (leftMode != null) {
      $result.leftMode = leftMode;
    }
    return $result;
  }
  SetPolarizationRequest._() : super();
  factory SetPolarizationRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetPolarizationRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetPolarizationRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..e<SetPolarizationRequest_PolarizationMode>(1, _omitFieldNames ? '' : 'rightMode', $pb.PbFieldType.OE, protoName: 'rightMode', defaultOrMaker: SetPolarizationRequest_PolarizationMode.Unpolarized, valueOf: SetPolarizationRequest_PolarizationMode.valueOf, enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..e<SetPolarizationRequest_PolarizationMode>(2, _omitFieldNames ? '' : 'leftMode', $pb.PbFieldType.OE, protoName: 'leftMode', defaultOrMaker: SetPolarizationRequest_PolarizationMode.Unpolarized, valueOf: SetPolarizationRequest_PolarizationMode.valueOf, enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetPolarizationRequest clone() => SetPolarizationRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetPolarizationRequest copyWith(void Function(SetPolarizationRequest) updates) => super.copyWith((message) => updates(message as SetPolarizationRequest)) as SetPolarizationRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPolarizationRequest create() => SetPolarizationRequest._();
  SetPolarizationRequest createEmptyInstance() => create();
  static $pb.PbList<SetPolarizationRequest> createRepeated() => $pb.PbList<SetPolarizationRequest>();
  @$core.pragma('dart2js:noInline')
  static SetPolarizationRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetPolarizationRequest>(create);
  static SetPolarizationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SetPolarizationRequest_PolarizationMode get rightMode => $_getN(0);
  @$pb.TagNumber(1)
  set rightMode(SetPolarizationRequest_PolarizationMode v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRightMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRightMode() => $_clearField(1);

  @$pb.TagNumber(2)
  SetPolarizationRequest_PolarizationMode get leftMode => $_getN(1);
  @$pb.TagNumber(2)
  set leftMode(SetPolarizationRequest_PolarizationMode v) { $_setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLeftMode() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeftMode() => $_clearField(2);
}

class LaserRequest extends $pb.GeneratedMessage {
  factory LaserRequest({
    $core.bool? isActive,
  }) {
    final $result = create();
    if (isActive != null) {
      $result.isActive = isActive;
    }
    return $result;
  }
  LaserRequest._() : super();
  factory LaserRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory LaserRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LaserRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isActive', protoName: 'isActive')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  LaserRequest clone() => LaserRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  LaserRequest copyWith(void Function(LaserRequest) updates) => super.copyWith((message) => updates(message as LaserRequest)) as LaserRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LaserRequest create() => LaserRequest._();
  LaserRequest createEmptyInstance() => create();
  static $pb.PbList<LaserRequest> createRepeated() => $pb.PbList<LaserRequest>();
  @$core.pragma('dart2js:noInline')
  static LaserRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LaserRequest>(create);
  static LaserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isActive => $_getBF(0);
  @$pb.TagNumber(1)
  set isActive($core.bool v) { $_setBool(0, v); }
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
    final $result = create();
    if (rightMode != null) {
      $result.rightMode = rightMode;
    }
    if (leftMode != null) {
      $result.leftMode = leftMode;
    }
    return $result;
  }
  PolarizationModeResponse._() : super();
  factory PolarizationModeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PolarizationModeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PolarizationModeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..e<SetPolarizationRequest_PolarizationMode>(1, _omitFieldNames ? '' : 'rightMode', $pb.PbFieldType.OE, protoName: 'rightMode', defaultOrMaker: SetPolarizationRequest_PolarizationMode.Unpolarized, valueOf: SetPolarizationRequest_PolarizationMode.valueOf, enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..e<SetPolarizationRequest_PolarizationMode>(2, _omitFieldNames ? '' : 'leftMode', $pb.PbFieldType.OE, protoName: 'leftMode', defaultOrMaker: SetPolarizationRequest_PolarizationMode.Unpolarized, valueOf: SetPolarizationRequest_PolarizationMode.valueOf, enumValues: SetPolarizationRequest_PolarizationMode.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PolarizationModeResponse clone() => PolarizationModeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PolarizationModeResponse copyWith(void Function(PolarizationModeResponse) updates) => super.copyWith((message) => updates(message as PolarizationModeResponse)) as PolarizationModeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PolarizationModeResponse create() => PolarizationModeResponse._();
  PolarizationModeResponse createEmptyInstance() => create();
  static $pb.PbList<PolarizationModeResponse> createRepeated() => $pb.PbList<PolarizationModeResponse>();
  @$core.pragma('dart2js:noInline')
  static PolarizationModeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PolarizationModeResponse>(create);
  static PolarizationModeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SetPolarizationRequest_PolarizationMode get rightMode => $_getN(0);
  @$pb.TagNumber(1)
  set rightMode(SetPolarizationRequest_PolarizationMode v) { $_setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRightMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearRightMode() => $_clearField(1);

  @$pb.TagNumber(2)
  SetPolarizationRequest_PolarizationMode get leftMode => $_getN(1);
  @$pb.TagNumber(2)
  set leftMode(SetPolarizationRequest_PolarizationMode v) { $_setField(2, v); }
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
    final $result = create();
    if (major != null) {
      $result.major = major;
    }
    if (minor != null) {
      $result.minor = minor;
    }
    return $result;
  }
  VersionResponse._() : super();
  factory VersionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VersionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VersionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'major', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'minor', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VersionResponse clone() => VersionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VersionResponse copyWith(void Function(VersionResponse) updates) => super.copyWith((message) => updates(message as VersionResponse)) as VersionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VersionResponse create() => VersionResponse._();
  VersionResponse createEmptyInstance() => create();
  static $pb.PbList<VersionResponse> createRepeated() => $pb.PbList<VersionResponse>();
  @$core.pragma('dart2js:noInline')
  static VersionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VersionResponse>(create);
  static VersionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get major => $_getIZ(0);
  @$pb.TagNumber(1)
  set major($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMajor() => $_has(0);
  @$pb.TagNumber(1)
  void clearMajor() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get minor => $_getIZ(1);
  @$pb.TagNumber(2)
  set minor($core.int v) { $_setSignedInt32(1, v); }
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
    final $result = create();
    if (percentageRight != null) {
      $result.percentageRight = percentageRight;
    }
    if (percentageLeft != null) {
      $result.percentageLeft = percentageLeft;
    }
    return $result;
  }
  FlashEnergyResponse._() : super();
  factory FlashEnergyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FlashEnergyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FlashEnergyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'polflash'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'percentageRight', $pb.PbFieldType.OD, protoName: 'percentageRight')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'percentageLeft', $pb.PbFieldType.OD, protoName: 'percentageLeft')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FlashEnergyResponse clone() => FlashEnergyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FlashEnergyResponse copyWith(void Function(FlashEnergyResponse) updates) => super.copyWith((message) => updates(message as FlashEnergyResponse)) as FlashEnergyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FlashEnergyResponse create() => FlashEnergyResponse._();
  FlashEnergyResponse createEmptyInstance() => create();
  static $pb.PbList<FlashEnergyResponse> createRepeated() => $pb.PbList<FlashEnergyResponse>();
  @$core.pragma('dart2js:noInline')
  static FlashEnergyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FlashEnergyResponse>(create);
  static FlashEnergyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get percentageRight => $_getN(0);
  @$pb.TagNumber(1)
  set percentageRight($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPercentageRight() => $_has(0);
  @$pb.TagNumber(1)
  void clearPercentageRight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get percentageLeft => $_getN(1);
  @$pb.TagNumber(2)
  set percentageLeft($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPercentageLeft() => $_has(1);
  @$pb.TagNumber(2)
  void clearPercentageLeft() => $_clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
