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

import 'package:protobuf/protobuf.dart' as $pb;

class ZoomRequest_SidedSpeed_Direction extends $pb.ProtobufEnum {
  static const ZoomRequest_SidedSpeed_Direction WIDE =
      ZoomRequest_SidedSpeed_Direction._(0, _omitEnumNames ? '' : 'WIDE');
  static const ZoomRequest_SidedSpeed_Direction TELE =
      ZoomRequest_SidedSpeed_Direction._(1, _omitEnumNames ? '' : 'TELE');

  static const $core.List<ZoomRequest_SidedSpeed_Direction> values =
      <ZoomRequest_SidedSpeed_Direction>[
    WIDE,
    TELE,
  ];

  static final $core.List<ZoomRequest_SidedSpeed_Direction?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static ZoomRequest_SidedSpeed_Direction? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ZoomRequest_SidedSpeed_Direction._(super.value, super.name);
}

class SetFocusModeRequest_Mode extends $pb.ProtobufEnum {
  static const SetFocusModeRequest_Mode AUTO =
      SetFocusModeRequest_Mode._(0, _omitEnumNames ? '' : 'AUTO');
  static const SetFocusModeRequest_Mode MANUAL =
      SetFocusModeRequest_Mode._(1, _omitEnumNames ? '' : 'MANUAL');

  static const $core.List<SetFocusModeRequest_Mode> values =
      <SetFocusModeRequest_Mode>[
    AUTO,
    MANUAL,
  ];

  static final $core.List<SetFocusModeRequest_Mode?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static SetFocusModeRequest_Mode? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SetFocusModeRequest_Mode._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
