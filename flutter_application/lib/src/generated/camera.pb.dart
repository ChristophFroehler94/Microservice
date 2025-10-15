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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
  PowerRequest clone() => deepCopy();
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

class ZoomRequest extends $pb.GeneratedMessage {
  factory ZoomRequest({
    $core.int? position,
  }) {
    final result = create();
    if (position != null) result.position = position;
    return result;
  }

  ZoomRequest._();

  factory ZoomRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ZoomRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ZoomRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'camera.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'position', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoomRequest clone() => deepCopy();
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

  @$pb.TagNumber(1)
  $core.int get position => $_getIZ(0);
  @$pb.TagNumber(1)
  set position($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPosition() => $_has(0);
  @$pb.TagNumber(1)
  void clearPosition() => $_clearField(1);
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
  StatusReply clone() => deepCopy();
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
  }) {
    final result = create();
    if (poweredOn != null) result.poweredOn = poweredOn;
    if (zoomPos != null) result.zoomPos = zoomPos;
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
    ..aI(2, _omitFieldNames ? '' : 'zoomPos',
        protoName: 'zoomPos', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CameraStatus clone() => deepCopy();
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
}

class StreamH264Request extends $pb.GeneratedMessage {
  factory StreamH264Request({
    $core.int? width,
    $core.int? height,
    $core.int? fps,
    $core.int? bitrate,
  }) {
    final result = create();
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
    ..aI(1, _omitFieldNames ? '' : 'width')
    ..aI(2, _omitFieldNames ? '' : 'height')
    ..aI(3, _omitFieldNames ? '' : 'fps')
    ..aI(4, _omitFieldNames ? '' : 'bitrate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StreamH264Request clone() => deepCopy();
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
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get fps => $_getIZ(2);
  @$pb.TagNumber(3)
  set fps($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFps() => $_has(2);
  @$pb.TagNumber(3)
  void clearFps() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get bitrate => $_getIZ(3);
  @$pb.TagNumber(4)
  set bitrate($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBitrate() => $_has(3);
  @$pb.TagNumber(4)
  void clearBitrate() => $_clearField(4);
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
  TsChunk clone() => deepCopy();
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
    $core.int? width,
    $core.int? height,
    $core.String? format,
  }) {
    final result = create();
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
    ..aI(1, _omitFieldNames ? '' : 'width')
    ..aI(2, _omitFieldNames ? '' : 'height')
    ..aOS(3, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SnapshotRequest clone() => deepCopy();
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
  $core.int get width => $_getIZ(0);
  @$pb.TagNumber(1)
  set width($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWidth() => $_has(0);
  @$pb.TagNumber(1)
  void clearWidth() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get format => $_getSZ(2);
  @$pb.TagNumber(3)
  set format($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFormat() => $_has(2);
  @$pb.TagNumber(3)
  void clearFormat() => $_clearField(3);
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
  SnapshotReply clone() => deepCopy();
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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
