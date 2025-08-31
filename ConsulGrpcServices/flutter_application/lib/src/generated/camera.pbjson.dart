// This is a generated file - do not edit.
//
// Generated from camera.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use streamH264RequestDescriptor instead')
const StreamH264Request$json = {
  '1': 'StreamH264Request',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '10': 'height'},
    {'1': 'fps', '3': 4, '4': 1, '5': 5, '10': 'fps'},
    {'1': 'bitrate', '3': 5, '4': 1, '5': 5, '10': 'bitrate'},
  ],
};

/// Descriptor for `StreamH264Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamH264RequestDescriptor = $convert.base64Decode(
    'ChFTdHJlYW1IMjY0UmVxdWVzdBIbCglkZXZpY2VfaWQYASABKAlSCGRldmljZUlkEhQKBXdpZH'
    'RoGAIgASgFUgV3aWR0aBIWCgZoZWlnaHQYAyABKAVSBmhlaWdodBIQCgNmcHMYBCABKAVSA2Zw'
    'cxIYCgdiaXRyYXRlGAUgASgFUgdiaXRyYXRl');

@$core.Deprecated('Use tsChunkDescriptor instead')
const TsChunk$json = {
  '1': 'TsChunk',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `TsChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tsChunkDescriptor =
    $convert.base64Decode('CgdUc0NodW5rEhIKBGRhdGEYASABKAxSBGRhdGE=');

@$core.Deprecated('Use snapshotRequestDescriptor instead')
const SnapshotRequest$json = {
  '1': 'SnapshotRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '10': 'height'},
    {'1': 'format', '3': 4, '4': 1, '5': 9, '10': 'format'},
  ],
};

/// Descriptor for `SnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotRequestDescriptor = $convert.base64Decode(
    'Cg9TbmFwc2hvdFJlcXVlc3QSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZBIUCgV3aWR0aB'
    'gCIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAMgASgFUgZoZWlnaHQSFgoGZm9ybWF0GAQgASgJUgZm'
    'b3JtYXQ=');

@$core.Deprecated('Use snapshotReplyDescriptor instead')
const SnapshotReply$json = {
  '1': 'SnapshotReply',
  '2': [
    {'1': 'image', '3': 1, '4': 1, '5': 12, '10': 'image'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `SnapshotReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotReplyDescriptor = $convert.base64Decode(
    'Cg1TbmFwc2hvdFJlcGx5EhQKBWltYWdlGAEgASgMUgVpbWFnZRIcCgl0aW1lc3RhbXAYAiABKA'
    'NSCXRpbWVzdGFtcA==');

@$core.Deprecated('Use powerRequestDescriptor instead')
const PowerRequest$json = {
  '1': 'PowerRequest',
  '2': [
    {'1': 'on', '3': 1, '4': 1, '5': 8, '10': 'on'},
  ],
};

/// Descriptor for `PowerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List powerRequestDescriptor =
    $convert.base64Decode('CgxQb3dlclJlcXVlc3QSDgoCb24YASABKAhSAm9u');

@$core.Deprecated('Use zoomRequestDescriptor instead')
const ZoomRequest$json = {
  '1': 'ZoomRequest',
  '2': [
    {'1': 'direct', '3': 1, '4': 1, '5': 13, '9': 0, '10': 'direct'},
    {
      '1': 'variable',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.camera.v1.ZoomRequest.SidedSpeed',
      '9': 0,
      '10': 'variable'
    },
    {'1': 'stop', '3': 3, '4': 1, '5': 8, '9': 0, '10': 'stop'},
  ],
  '3': [ZoomRequest_SidedSpeed$json],
  '8': [
    {'1': 'kind'},
  ],
};

@$core.Deprecated('Use zoomRequestDescriptor instead')
const ZoomRequest_SidedSpeed$json = {
  '1': 'SidedSpeed',
  '2': [
    {
      '1': 'dir',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.camera.v1.ZoomRequest.SidedSpeed.Direction',
      '10': 'dir'
    },
    {'1': 'speed', '3': 2, '4': 1, '5': 13, '10': 'speed'},
  ],
  '4': [ZoomRequest_SidedSpeed_Direction$json],
};

@$core.Deprecated('Use zoomRequestDescriptor instead')
const ZoomRequest_SidedSpeed_Direction$json = {
  '1': 'Direction',
  '2': [
    {'1': 'WIDE', '2': 0},
    {'1': 'TELE', '2': 1},
  ],
};

/// Descriptor for `ZoomRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List zoomRequestDescriptor = $convert.base64Decode(
    'Cgtab29tUmVxdWVzdBIYCgZkaXJlY3QYASABKA1IAFIGZGlyZWN0Ej8KCHZhcmlhYmxlGAIgAS'
    'gLMiEuY2FtZXJhLnYxLlpvb21SZXF1ZXN0LlNpZGVkU3BlZWRIAFIIdmFyaWFibGUSFAoEc3Rv'
    'cBgDIAEoCEgAUgRzdG9wGoIBCgpTaWRlZFNwZWVkEj0KA2RpchgBIAEoDjIrLmNhbWVyYS52MS'
    '5ab29tUmVxdWVzdC5TaWRlZFNwZWVkLkRpcmVjdGlvblIDZGlyEhQKBXNwZWVkGAIgASgNUgVz'
    'cGVlZCIfCglEaXJlY3Rpb24SCAoEV0lERRAAEggKBFRFTEUQAUIGCgRraW5k');

@$core.Deprecated('Use setFocusModeRequestDescriptor instead')
const SetFocusModeRequest$json = {
  '1': 'SetFocusModeRequest',
  '2': [
    {
      '1': 'mode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.camera.v1.SetFocusModeRequest.Mode',
      '10': 'mode'
    },
  ],
  '4': [SetFocusModeRequest_Mode$json],
};

@$core.Deprecated('Use setFocusModeRequestDescriptor instead')
const SetFocusModeRequest_Mode$json = {
  '1': 'Mode',
  '2': [
    {'1': 'AUTO', '2': 0},
    {'1': 'MANUAL', '2': 1},
  ],
};

/// Descriptor for `SetFocusModeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFocusModeRequestDescriptor = $convert.base64Decode(
    'ChNTZXRGb2N1c01vZGVSZXF1ZXN0EjcKBG1vZGUYASABKA4yIy5jYW1lcmEudjEuU2V0Rm9jdX'
    'NNb2RlUmVxdWVzdC5Nb2RlUgRtb2RlIhwKBE1vZGUSCAoEQVVUTxAAEgoKBk1BTlVBTBAB');

@$core.Deprecated('Use setFocusPositionRequestDescriptor instead')
const SetFocusPositionRequest$json = {
  '1': 'SetFocusPositionRequest',
  '2': [
    {'1': 'direct', '3': 1, '4': 1, '5': 13, '10': 'direct'},
  ],
};

/// Descriptor for `SetFocusPositionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFocusPositionRequestDescriptor =
    $convert.base64Decode(
        'ChdTZXRGb2N1c1Bvc2l0aW9uUmVxdWVzdBIWCgZkaXJlY3QYASABKA1SBmRpcmVjdA==');

@$core.Deprecated('Use statusReplyDescriptor instead')
const StatusReply$json = {
  '1': 'StatusReply',
  '2': [
    {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `StatusReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List statusReplyDescriptor = $convert.base64Decode(
    'CgtTdGF0dXNSZXBseRIOCgJvaxgBIAEoCFICb2sSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ'
    '==');

@$core.Deprecated('Use cameraStatusDescriptor instead')
const CameraStatus$json = {
  '1': 'CameraStatus',
  '2': [
    {'1': 'poweredOn', '3': 1, '4': 1, '5': 8, '10': 'poweredOn'},
    {'1': 'zoomPos', '3': 2, '4': 1, '5': 13, '10': 'zoomPos'},
    {'1': 'focusPos', '3': 3, '4': 1, '5': 13, '10': 'focusPos'},
  ],
};

/// Descriptor for `CameraStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cameraStatusDescriptor = $convert.base64Decode(
    'CgxDYW1lcmFTdGF0dXMSHAoJcG93ZXJlZE9uGAEgASgIUglwb3dlcmVkT24SGAoHem9vbVBvcx'
    'gCIAEoDVIHem9vbVBvcxIaCghmb2N1c1BvcxgDIAEoDVIIZm9jdXNQb3M=');
