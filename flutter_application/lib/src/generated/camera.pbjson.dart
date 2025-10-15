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
    {'1': 'position', '3': 1, '4': 1, '5': 13, '10': 'position'},
  ],
};

/// Descriptor for `ZoomRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List zoomRequestDescriptor = $convert
    .base64Decode('Cgtab29tUmVxdWVzdBIaCghwb3NpdGlvbhgBIAEoDVIIcG9zaXRpb24=');

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
  ],
};

/// Descriptor for `CameraStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cameraStatusDescriptor = $convert.base64Decode(
    'CgxDYW1lcmFTdGF0dXMSHAoJcG93ZXJlZE9uGAEgASgIUglwb3dlcmVkT24SGAoHem9vbVBvcx'
    'gCIAEoDVIHem9vbVBvcw==');

@$core.Deprecated('Use streamH264RequestDescriptor instead')
const StreamH264Request$json = {
  '1': 'StreamH264Request',
  '2': [
    {'1': 'width', '3': 1, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 5, '10': 'height'},
    {'1': 'fps', '3': 3, '4': 1, '5': 5, '10': 'fps'},
    {'1': 'bitrate', '3': 4, '4': 1, '5': 5, '10': 'bitrate'},
  ],
};

/// Descriptor for `StreamH264Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List streamH264RequestDescriptor = $convert.base64Decode(
    'ChFTdHJlYW1IMjY0UmVxdWVzdBIUCgV3aWR0aBgBIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAIgAS'
    'gFUgZoZWlnaHQSEAoDZnBzGAMgASgFUgNmcHMSGAoHYml0cmF0ZRgEIAEoBVIHYml0cmF0ZQ==');

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
    {'1': 'width', '3': 1, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 2, '4': 1, '5': 5, '10': 'height'},
    {'1': 'format', '3': 3, '4': 1, '5': 9, '10': 'format'},
  ],
};

/// Descriptor for `SnapshotRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List snapshotRequestDescriptor = $convert.base64Decode(
    'Cg9TbmFwc2hvdFJlcXVlc3QSFAoFd2lkdGgYASABKAVSBXdpZHRoEhYKBmhlaWdodBgCIAEoBV'
    'IGaGVpZ2h0EhYKBmZvcm1hdBgDIAEoCVIGZm9ybWF0');

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
