//
//  Generated code. Do not modify.
//  source: camera.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'camera.pb.dart' as $0;
import 'google/protobuf/empty.pb.dart' as $1;

export 'camera.pb.dart';

@$pb.GrpcServiceName('camera.v1.CameraService')
class CameraServiceClient extends $grpc.Client {
  static final _$power = $grpc.ClientMethod<$0.PowerRequest, $0.StatusReply>(
      '/camera.v1.CameraService/Power',
      ($0.PowerRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.StatusReply.fromBuffer(value));
  static final _$zoom = $grpc.ClientMethod<$0.ZoomRequest, $0.StatusReply>(
      '/camera.v1.CameraService/Zoom',
      ($0.ZoomRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.StatusReply.fromBuffer(value));
  static final _$getStatus = $grpc.ClientMethod<$1.Empty, $0.CameraStatus>(
      '/camera.v1.CameraService/GetStatus',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.CameraStatus.fromBuffer(value));
  static final _$streamTs = $grpc.ClientMethod<$0.StreamH264Request, $0.TsChunk>(
      '/camera.v1.CameraService/StreamTs',
      ($0.StreamH264Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TsChunk.fromBuffer(value));
  static final _$takeSnapshot = $grpc.ClientMethod<$0.SnapshotRequest, $0.SnapshotReply>(
      '/camera.v1.CameraService/TakeSnapshot',
      ($0.SnapshotRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SnapshotReply.fromBuffer(value));

  CameraServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.StatusReply> power($0.PowerRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$power, request, options: options);
  }

  $grpc.ResponseFuture<$0.StatusReply> zoom($0.ZoomRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$zoom, request, options: options);
  }

  $grpc.ResponseFuture<$0.CameraStatus> getStatus($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getStatus, request, options: options);
  }

  $grpc.ResponseStream<$0.TsChunk> streamTs($0.StreamH264Request request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$streamTs, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.SnapshotReply> takeSnapshot($0.SnapshotRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$takeSnapshot, request, options: options);
  }
}

@$pb.GrpcServiceName('camera.v1.CameraService')
abstract class CameraServiceBase extends $grpc.Service {
  $core.String get $name => 'camera.v1.CameraService';

  CameraServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PowerRequest, $0.StatusReply>(
        'Power',
        power_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PowerRequest.fromBuffer(value),
        ($0.StatusReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ZoomRequest, $0.StatusReply>(
        'Zoom',
        zoom_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ZoomRequest.fromBuffer(value),
        ($0.StatusReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.CameraStatus>(
        'GetStatus',
        getStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.CameraStatus value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StreamH264Request, $0.TsChunk>(
        'StreamTs',
        streamTs_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.StreamH264Request.fromBuffer(value),
        ($0.TsChunk value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SnapshotRequest, $0.SnapshotReply>(
        'TakeSnapshot',
        takeSnapshot_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SnapshotRequest.fromBuffer(value),
        ($0.SnapshotReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.StatusReply> power_Pre($grpc.ServiceCall $call, $async.Future<$0.PowerRequest> $request) async {
    return power($call, await $request);
  }

  $async.Future<$0.StatusReply> zoom_Pre($grpc.ServiceCall $call, $async.Future<$0.ZoomRequest> $request) async {
    return zoom($call, await $request);
  }

  $async.Future<$0.CameraStatus> getStatus_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getStatus($call, await $request);
  }

  $async.Stream<$0.TsChunk> streamTs_Pre($grpc.ServiceCall $call, $async.Future<$0.StreamH264Request> $request) async* {
    yield* streamTs($call, await $request);
  }

  $async.Future<$0.SnapshotReply> takeSnapshot_Pre($grpc.ServiceCall $call, $async.Future<$0.SnapshotRequest> $request) async {
    return takeSnapshot($call, await $request);
  }

  $async.Future<$0.StatusReply> power($grpc.ServiceCall call, $0.PowerRequest request);
  $async.Future<$0.StatusReply> zoom($grpc.ServiceCall call, $0.ZoomRequest request);
  $async.Future<$0.CameraStatus> getStatus($grpc.ServiceCall call, $1.Empty request);
  $async.Stream<$0.TsChunk> streamTs($grpc.ServiceCall call, $0.StreamH264Request request);
  $async.Future<$0.SnapshotReply> takeSnapshot($grpc.ServiceCall call, $0.SnapshotRequest request);
}
