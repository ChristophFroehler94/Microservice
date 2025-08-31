// This is a generated file - do not edit.
//
// Generated from camera.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'camera.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'camera.pbenum.dart';

class StreamH264Request extends $pb.GeneratedMessage {
  factory StreamH264Request({
    $core.String? deviceId,
    $core.int? width,
    $core.int? height,
    $core.int? fps,
    $core.int? bitrate,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (fps != null) result.fps = fps;
    if (bitrate != null) result.bitrate = bitrate;
    return result;
  }

  StreamH264Request._();

  factory StreamH264Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StreamH264Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StreamH264Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'fps', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'bitrate', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamH264Request clone() => StreamH264Request()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamH264Request copyWith(void Function(StreamH264Request) updates) =>
      super.copyWith((message) => updates(message as StreamH264Request))
          as StreamH264Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StreamH264Request create() => StreamH264Request._();
  @$core.override
  StreamH264Request createEmptyInstance() => create();
  static $pb.PbList<StreamH264Request> createRepeated() =>
      $pb.PbList<StreamH264Request>();
  @$core.pragma('dart2js:noInline')
  static StreamH264Request getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StreamH264Request>(create);
  static StreamH264Request? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get fps => $_getIZ(3);
  @$pb.TagNumber(4)
  set fps($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFps() => $_has(3);
  @$pb.TagNumber(4)
  void clearFps() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get bitrate => $_getIZ(4);
  @$pb.TagNumber(5)
  set bitrate($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBitrate() => $_has(4);
  @$pb.TagNumber(5)
  void clearBitrate() => $_clearField(5);
}

class TsChunk extends $pb.GeneratedMessage {
  factory TsChunk({
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (data != null) result.data = data;
    return result;
  }

  TsChunk._();

  factory TsChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TsChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TsChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TsChunk clone() => TsChunk()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TsChunk copyWith(void Function(TsChunk) updates) =>
      super.copyWith((message) => updates(message as TsChunk)) as TsChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TsChunk create() => TsChunk._();
  @$core.override
  TsChunk createEmptyInstance() => create();
  static $pb.PbList<TsChunk> createRepeated() => $pb.PbList<TsChunk>();
  @$core.pragma('dart2js:noInline')
  static TsChunk getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TsChunk>(create);
  static TsChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => $_clearField(1);
}

class SnapshotRequest extends $pb.GeneratedMessage {
  factory SnapshotRequest({
    $core.String? deviceId,
    $core.int? width,
    $core.int? height,
    $core.String? format,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (format != null) result.format = format;
    return result;
  }

  SnapshotRequest._();

  factory SnapshotRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SnapshotRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SnapshotRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'width', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aOS(4, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotRequest clone() => SnapshotRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotRequest copyWith(void Function(SnapshotRequest) updates) =>
      super.copyWith((message) => updates(message as SnapshotRequest))
          as SnapshotRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SnapshotRequest create() => SnapshotRequest._();
  @$core.override
  SnapshotRequest createEmptyInstance() => create();
  static $pb.PbList<SnapshotRequest> createRepeated() =>
      $pb.PbList<SnapshotRequest>();
  @$core.pragma('dart2js:noInline')
  static SnapshotRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SnapshotRequest>(create);
  static SnapshotRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get format => $_getSZ(3);
  @$pb.TagNumber(4)
  set format($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormat() => $_clearField(4);
}

class SnapshotReply extends $pb.GeneratedMessage {
  factory SnapshotReply({
    $core.List<$core.int>? image,
    $fixnum.Int64? timestamp,
  }) {
    final result = create();
    if (image != null) result.image = image;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  SnapshotReply._();

  factory SnapshotReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SnapshotReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SnapshotReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'image', $pb.PbFieldType.OY)
    ..aInt64(2, _omitFieldNames ? '' : 'timestamp')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotReply clone() => SnapshotReply()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotReply copyWith(void Function(SnapshotReply) updates) =>
      super.copyWith((message) => updates(message as SnapshotReply))
          as SnapshotReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SnapshotReply create() => SnapshotReply._();
  @$core.override
  SnapshotReply createEmptyInstance() => create();
  static $pb.PbList<SnapshotReply> createRepeated() =>
      $pb.PbList<SnapshotReply>();
  @$core.pragma('dart2js:noInline')
  static SnapshotReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SnapshotReply>(create);
  static SnapshotReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get image => $_getN(0);
  @$pb.TagNumber(1)
  set image($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImage() => $_has(0);
  @$pb.TagNumber(1)
  void clearImage() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get timestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set timestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);
}

class PowerRequest extends $pb.GeneratedMessage {
  factory PowerRequest({
    $core.bool? on,
  }) {
    final result = create();
    if (on != null) result.on = on;
    return result;
  }

  PowerRequest._();

  factory PowerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PowerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PowerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'on')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerRequest clone() => PowerRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PowerRequest copyWith(void Function(PowerRequest) updates) =>
      super.copyWith((message) => updates(message as PowerRequest))
          as PowerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PowerRequest create() => PowerRequest._();
  @$core.override
  PowerRequest createEmptyInstance() => create();
  static $pb.PbList<PowerRequest> createRepeated() =>
      $pb.PbList<PowerRequest>();
  @$core.pragma('dart2js:noInline')
  static PowerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PowerRequest>(create);
  static PowerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get on => $_getBF(0);
  @$pb.TagNumber(1)
  set on($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOn() => $_has(0);
  @$pb.TagNumber(1)
  void clearOn() => $_clearField(1);
}

class ZoomRequest_SidedSpeed extends $pb.GeneratedMessage {
  factory ZoomRequest_SidedSpeed({
    ZoomRequest_SidedSpeed_Direction? dir,
    $core.int? speed,
  }) {
    final result = create();
    if (dir != null) result.dir = dir;
    if (speed != null) result.speed = speed;
    return result;
  }

  ZoomRequest_SidedSpeed._();

  factory ZoomRequest_SidedSpeed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ZoomRequest_SidedSpeed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ZoomRequest.SidedSpeed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..e<ZoomRequest_SidedSpeed_Direction>(
        1, _omitFieldNames ? '' : 'dir', $pb.PbFieldType.OE,
        defaultOrMaker: ZoomRequest_SidedSpeed_Direction.WIDE,
        valueOf: ZoomRequest_SidedSpeed_Direction.valueOf,
        enumValues: ZoomRequest_SidedSpeed_Direction.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'speed', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoomRequest_SidedSpeed clone() =>
      ZoomRequest_SidedSpeed()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoomRequest_SidedSpeed copyWith(
          void Function(ZoomRequest_SidedSpeed) updates) =>
      super.copyWith((message) => updates(message as ZoomRequest_SidedSpeed))
          as ZoomRequest_SidedSpeed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ZoomRequest_SidedSpeed create() => ZoomRequest_SidedSpeed._();
  @$core.override
  ZoomRequest_SidedSpeed createEmptyInstance() => create();
  static $pb.PbList<ZoomRequest_SidedSpeed> createRepeated() =>
      $pb.PbList<ZoomRequest_SidedSpeed>();
  @$core.pragma('dart2js:noInline')
  static ZoomRequest_SidedSpeed getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ZoomRequest_SidedSpeed>(create);
  static ZoomRequest_SidedSpeed? _defaultInstance;

  @$pb.TagNumber(1)
  ZoomRequest_SidedSpeed_Direction get dir => $_getN(0);
  @$pb.TagNumber(1)
  set dir(ZoomRequest_SidedSpeed_Direction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDir() => $_has(0);
  @$pb.TagNumber(1)
  void clearDir() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get speed => $_getIZ(1);
  @$pb.TagNumber(2)
  set speed($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSpeed() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpeed() => $_clearField(2);
}

enum ZoomRequest_Kind { direct, variable, stop, notSet }

class ZoomRequest extends $pb.GeneratedMessage {
  factory ZoomRequest({
    $core.int? direct,
    ZoomRequest_SidedSpeed? variable,
    $core.bool? stop,
  }) {
    final result = create();
    if (direct != null) result.direct = direct;
    if (variable != null) result.variable = variable;
    if (stop != null) result.stop = stop;
    return result;
  }

  ZoomRequest._();

  factory ZoomRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ZoomRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ZoomRequest_Kind> _ZoomRequest_KindByTag = {
    1: ZoomRequest_Kind.direct,
    2: ZoomRequest_Kind.variable,
    3: ZoomRequest_Kind.stop,
    0: ZoomRequest_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ZoomRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'direct', $pb.PbFieldType.OU3)
    ..aOM<ZoomRequest_SidedSpeed>(2, _omitFieldNames ? '' : 'variable',
        subBuilder: ZoomRequest_SidedSpeed.create)
    ..aOB(3, _omitFieldNames ? '' : 'stop')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoomRequest clone() => ZoomRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoomRequest copyWith(void Function(ZoomRequest) updates) =>
      super.copyWith((message) => updates(message as ZoomRequest))
          as ZoomRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ZoomRequest create() => ZoomRequest._();
  @$core.override
  ZoomRequest createEmptyInstance() => create();
  static $pb.PbList<ZoomRequest> createRepeated() => $pb.PbList<ZoomRequest>();
  @$core.pragma('dart2js:noInline')
  static ZoomRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ZoomRequest>(create);
  static ZoomRequest? _defaultInstance;

  ZoomRequest_Kind whichKind() => _ZoomRequest_KindByTag[$_whichOneof(0)]!;
  void clearKind() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get direct => $_getIZ(0);
  @$pb.TagNumber(1)
  set direct($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDirect() => $_has(0);
  @$pb.TagNumber(1)
  void clearDirect() => $_clearField(1);

  @$pb.TagNumber(2)
  ZoomRequest_SidedSpeed get variable => $_getN(1);
  @$pb.TagNumber(2)
  set variable(ZoomRequest_SidedSpeed value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVariable() => $_has(1);
  @$pb.TagNumber(2)
  void clearVariable() => $_clearField(2);
  @$pb.TagNumber(2)
  ZoomRequest_SidedSpeed ensureVariable() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.bool get stop => $_getBF(2);
  @$pb.TagNumber(3)
  set stop($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStop() => $_has(2);
  @$pb.TagNumber(3)
  void clearStop() => $_clearField(3);
}

class SetFocusModeRequest extends $pb.GeneratedMessage {
  factory SetFocusModeRequest({
    SetFocusModeRequest_Mode? mode,
  }) {
    final result = create();
    if (mode != null) result.mode = mode;
    return result;
  }

  SetFocusModeRequest._();

  factory SetFocusModeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFocusModeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFocusModeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..e<SetFocusModeRequest_Mode>(
        1, _omitFieldNames ? '' : 'mode', $pb.PbFieldType.OE,
        defaultOrMaker: SetFocusModeRequest_Mode.AUTO,
        valueOf: SetFocusModeRequest_Mode.valueOf,
        enumValues: SetFocusModeRequest_Mode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFocusModeRequest clone() => SetFocusModeRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFocusModeRequest copyWith(void Function(SetFocusModeRequest) updates) =>
      super.copyWith((message) => updates(message as SetFocusModeRequest))
          as SetFocusModeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFocusModeRequest create() => SetFocusModeRequest._();
  @$core.override
  SetFocusModeRequest createEmptyInstance() => create();
  static $pb.PbList<SetFocusModeRequest> createRepeated() =>
      $pb.PbList<SetFocusModeRequest>();
  @$core.pragma('dart2js:noInline')
  static SetFocusModeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFocusModeRequest>(create);
  static SetFocusModeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  SetFocusModeRequest_Mode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(SetFocusModeRequest_Mode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);
}

class SetFocusPositionRequest extends $pb.GeneratedMessage {
  factory SetFocusPositionRequest({
    $core.int? direct,
  }) {
    final result = create();
    if (direct != null) result.direct = direct;
    return result;
  }

  SetFocusPositionRequest._();

  factory SetFocusPositionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFocusPositionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFocusPositionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'direct', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFocusPositionRequest clone() =>
      SetFocusPositionRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFocusPositionRequest copyWith(
          void Function(SetFocusPositionRequest) updates) =>
      super.copyWith((message) => updates(message as SetFocusPositionRequest))
          as SetFocusPositionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFocusPositionRequest create() => SetFocusPositionRequest._();
  @$core.override
  SetFocusPositionRequest createEmptyInstance() => create();
  static $pb.PbList<SetFocusPositionRequest> createRepeated() =>
      $pb.PbList<SetFocusPositionRequest>();
  @$core.pragma('dart2js:noInline')
  static SetFocusPositionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFocusPositionRequest>(create);
  static SetFocusPositionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get direct => $_getIZ(0);
  @$pb.TagNumber(1)
  set direct($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDirect() => $_has(0);
  @$pb.TagNumber(1)
  void clearDirect() => $_clearField(1);
}

class StatusReply extends $pb.GeneratedMessage {
  factory StatusReply({
    $core.bool? ok,
    $core.String? message,
  }) {
    final result = create();
    if (ok != null) result.ok = ok;
    if (message != null) result.message = message;
    return result;
  }

  StatusReply._();

  factory StatusReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StatusReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StatusReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'ok')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusReply clone() => StatusReply()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StatusReply copyWith(void Function(StatusReply) updates) =>
      super.copyWith((message) => updates(message as StatusReply))
          as StatusReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StatusReply create() => StatusReply._();
  @$core.override
  StatusReply createEmptyInstance() => create();
  static $pb.PbList<StatusReply> createRepeated() => $pb.PbList<StatusReply>();
  @$core.pragma('dart2js:noInline')
  static StatusReply getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StatusReply>(create);
  static StatusReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get ok => $_getBF(0);
  @$pb.TagNumber(1)
  set ok($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOk() => $_has(0);
  @$pb.TagNumber(1)
  void clearOk() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class CameraStatus extends $pb.GeneratedMessage {
  factory CameraStatus({
    $core.bool? poweredOn,
    $core.int? zoomPos,
    $core.int? focusPos,
  }) {
    final result = create();
    if (poweredOn != null) result.poweredOn = poweredOn;
    if (zoomPos != null) result.zoomPos = zoomPos;
    if (focusPos != null) result.focusPos = focusPos;
    return result;
  }

  CameraStatus._();

  factory CameraStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CameraStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CameraStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'poweredOn', protoName: 'poweredOn')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'zoomPos', $pb.PbFieldType.OU3,
        protoName: 'zoomPos')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'focusPos', $pb.PbFieldType.OU3,
        protoName: 'focusPos')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CameraStatus clone() => CameraStatus()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CameraStatus copyWith(void Function(CameraStatus) updates) =>
      super.copyWith((message) => updates(message as CameraStatus))
          as CameraStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CameraStatus create() => CameraStatus._();
  @$core.override
  CameraStatus createEmptyInstance() => create();
  static $pb.PbList<CameraStatus> createRepeated() =>
      $pb.PbList<CameraStatus>();
  @$core.pragma('dart2js:noInline')
  static CameraStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CameraStatus>(create);
  static CameraStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get poweredOn => $_getBF(0);
  @$pb.TagNumber(1)
  set poweredOn($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPoweredOn() => $_has(0);
  @$pb.TagNumber(1)
  void clearPoweredOn() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get zoomPos => $_getIZ(1);
  @$pb.TagNumber(2)
  set zoomPos($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasZoomPos() => $_has(1);
  @$pb.TagNumber(2)
  void clearZoomPos() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get focusPos => $_getIZ(2);
  @$pb.TagNumber(3)
  set focusPos($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFocusPos() => $_has(2);
  @$pb.TagNumber(3)
  void clearFocusPos() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
