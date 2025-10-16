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

class SetPolarizationRequest_PolarizationMode extends $pb.ProtobufEnum {
  static const SetPolarizationRequest_PolarizationMode Unpolarized = SetPolarizationRequest_PolarizationMode._(0, _omitEnumNames ? '' : 'Unpolarized');
  static const SetPolarizationRequest_PolarizationMode Polarized = SetPolarizationRequest_PolarizationMode._(1, _omitEnumNames ? '' : 'Polarized');

  static const $core.List<SetPolarizationRequest_PolarizationMode> values = <SetPolarizationRequest_PolarizationMode> [
    Unpolarized,
    Polarized,
  ];

  static final $core.Map<$core.int, SetPolarizationRequest_PolarizationMode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SetPolarizationRequest_PolarizationMode? valueOf($core.int value) => _byValue[value];

  const SetPolarizationRequest_PolarizationMode._(super.v, super.n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
