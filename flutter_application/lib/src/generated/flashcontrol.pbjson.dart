// This is a generated file - do not edit.
//
// Generated from flashcontrol.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use taskResultDescriptor instead')
const TaskResult$json = {
  '1': 'TaskResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `TaskResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List taskResultDescriptor = $convert.base64Decode(
    'CgpUYXNrUmVzdWx0EhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3MSGAoHbWVzc2FnZRgCIAEoCV'
    'IHbWVzc2FnZQ==');

@$core.Deprecated('Use flashStateResponseDescriptor instead')
const FlashStateResponse$json = {
  '1': 'FlashStateResponse',
  '2': [
    {'1': 'state', '3': 1, '4': 1, '5': 5, '10': 'state'},
  ],
};

/// Descriptor for `FlashStateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flashStateResponseDescriptor = $convert
    .base64Decode('ChJGbGFzaFN0YXRlUmVzcG9uc2USFAoFc3RhdGUYASABKAVSBXN0YXRl');

@$core.Deprecated('Use getFlashCountResponseDescriptor instead')
const GetFlashCountResponse$json = {
  '1': 'GetFlashCountResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `GetFlashCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFlashCountResponseDescriptor =
    $convert.base64Decode(
        'ChVHZXRGbGFzaENvdW50UmVzcG9uc2USFAoFY291bnQYASABKAVSBWNvdW50');

@$core.Deprecated('Use setFlashEnergyRequestDescriptor instead')
const SetFlashEnergyRequest$json = {
  '1': 'SetFlashEnergyRequest',
  '2': [
    {'1': 'percentageRight', '3': 1, '4': 1, '5': 1, '10': 'percentageRight'},
    {'1': 'percentageLeft', '3': 2, '4': 1, '5': 1, '10': 'percentageLeft'},
  ],
};

/// Descriptor for `SetFlashEnergyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFlashEnergyRequestDescriptor = $convert.base64Decode(
    'ChVTZXRGbGFzaEVuZXJneVJlcXVlc3QSKAoPcGVyY2VudGFnZVJpZ2h0GAEgASgBUg9wZXJjZW'
    '50YWdlUmlnaHQSJgoOcGVyY2VudGFnZUxlZnQYAiABKAFSDnBlcmNlbnRhZ2VMZWZ0');

@$core.Deprecated('Use setPolarizationRequestDescriptor instead')
const SetPolarizationRequest$json = {
  '1': 'SetPolarizationRequest',
  '2': [
    {
      '1': 'rightMode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.polflash.SetPolarizationRequest.PolarizationMode',
      '10': 'rightMode'
    },
    {
      '1': 'leftMode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.polflash.SetPolarizationRequest.PolarizationMode',
      '10': 'leftMode'
    },
  ],
  '4': [SetPolarizationRequest_PolarizationMode$json],
};

@$core.Deprecated('Use setPolarizationRequestDescriptor instead')
const SetPolarizationRequest_PolarizationMode$json = {
  '1': 'PolarizationMode',
  '2': [
    {'1': 'Unpolarized', '2': 0},
    {'1': 'Polarized', '2': 1},
  ],
};

/// Descriptor for `SetPolarizationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPolarizationRequestDescriptor = $convert.base64Decode(
    'ChZTZXRQb2xhcml6YXRpb25SZXF1ZXN0Ek8KCXJpZ2h0TW9kZRgBIAEoDjIxLnBvbGZsYXNoLl'
    'NldFBvbGFyaXphdGlvblJlcXVlc3QuUG9sYXJpemF0aW9uTW9kZVIJcmlnaHRNb2RlEk0KCGxl'
    'ZnRNb2RlGAIgASgOMjEucG9sZmxhc2guU2V0UG9sYXJpemF0aW9uUmVxdWVzdC5Qb2xhcml6YX'
    'Rpb25Nb2RlUghsZWZ0TW9kZSIyChBQb2xhcml6YXRpb25Nb2RlEg8KC1VucG9sYXJpemVkEAAS'
    'DQoJUG9sYXJpemVkEAE=');

@$core.Deprecated('Use laserRequestDescriptor instead')
const LaserRequest$json = {
  '1': 'LaserRequest',
  '2': [
    {'1': 'isActive', '3': 1, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `LaserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List laserRequestDescriptor = $convert
    .base64Decode('CgxMYXNlclJlcXVlc3QSGgoIaXNBY3RpdmUYASABKAhSCGlzQWN0aXZl');

@$core.Deprecated('Use polarizationModeResponseDescriptor instead')
const PolarizationModeResponse$json = {
  '1': 'PolarizationModeResponse',
  '2': [
    {
      '1': 'rightMode',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.polflash.SetPolarizationRequest.PolarizationMode',
      '10': 'rightMode'
    },
    {
      '1': 'leftMode',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.polflash.SetPolarizationRequest.PolarizationMode',
      '10': 'leftMode'
    },
  ],
};

/// Descriptor for `PolarizationModeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List polarizationModeResponseDescriptor = $convert.base64Decode(
    'ChhQb2xhcml6YXRpb25Nb2RlUmVzcG9uc2USTwoJcmlnaHRNb2RlGAEgASgOMjEucG9sZmxhc2'
    'guU2V0UG9sYXJpemF0aW9uUmVxdWVzdC5Qb2xhcml6YXRpb25Nb2RlUglyaWdodE1vZGUSTQoI'
    'bGVmdE1vZGUYAiABKA4yMS5wb2xmbGFzaC5TZXRQb2xhcml6YXRpb25SZXF1ZXN0LlBvbGFyaX'
    'phdGlvbk1vZGVSCGxlZnRNb2Rl');

@$core.Deprecated('Use versionResponseDescriptor instead')
const VersionResponse$json = {
  '1': 'VersionResponse',
  '2': [
    {'1': 'major', '3': 1, '4': 1, '5': 5, '10': 'major'},
    {'1': 'minor', '3': 2, '4': 1, '5': 5, '10': 'minor'},
  ],
};

/// Descriptor for `VersionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List versionResponseDescriptor = $convert.base64Decode(
    'Cg9WZXJzaW9uUmVzcG9uc2USFAoFbWFqb3IYASABKAVSBW1ham9yEhQKBW1pbm9yGAIgASgFUg'
    'VtaW5vcg==');

@$core.Deprecated('Use flashEnergyResponseDescriptor instead')
const FlashEnergyResponse$json = {
  '1': 'FlashEnergyResponse',
  '2': [
    {'1': 'percentageRight', '3': 1, '4': 1, '5': 1, '10': 'percentageRight'},
    {'1': 'percentageLeft', '3': 2, '4': 1, '5': 1, '10': 'percentageLeft'},
  ],
};

/// Descriptor for `FlashEnergyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List flashEnergyResponseDescriptor = $convert.base64Decode(
    'ChNGbGFzaEVuZXJneVJlc3BvbnNlEigKD3BlcmNlbnRhZ2VSaWdodBgBIAEoAVIPcGVyY2VudG'
    'FnZVJpZ2h0EiYKDnBlcmNlbnRhZ2VMZWZ0GAIgASgBUg5wZXJjZW50YWdlTGVmdA==');
