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

class SetPolarizationRequest_PolarizationMode extends $pb.ProtobufEnum {
  static const SetPolarizationRequest_PolarizationMode Unpolarized =
      SetPolarizationRequest_PolarizationMode._(
          0, _omitEnumNames ? '' : 'Unpolarized');
  static const SetPolarizationRequest_PolarizationMode Polarized =
      SetPolarizationRequest_PolarizationMode._(
          1, _omitEnumNames ? '' : 'Polarized');

  static const $core.List<SetPolarizationRequest_PolarizationMode> values =
      <SetPolarizationRequest_PolarizationMode>[
    Unpolarized,
    Polarized,
  ];

  static final $core.List<SetPolarizationRequest_PolarizationMode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SetPolarizationRequest_PolarizationMode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SetPolarizationRequest_PolarizationMode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
