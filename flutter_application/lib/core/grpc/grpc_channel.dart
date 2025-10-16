// lib/core/grpc/grpc_channel.dart
// Zentrale Erzeugung von gRPC-Channels (TLS mit Root-CA).
// 'authority' setzt :authority (und i.d.R. SNI) – nur bei DNS nötig. :contentReference[oaicite:8]{index=8}

import 'package:grpc/grpc.dart';

class GrpcChannelFactory {
  /// TLS-Channel mit Root-CA-Trust (kein End-Entity-Pinning).
  static ClientChannel secure(
    String host,
    int port, {
    required List<int> trustedCaPem,
    String? authority,
  }) {
    final creds = ChannelCredentials.secure(
      certificates: trustedCaPem, // Root-CA(s) für diesen Channel
      authority: authority,       // optional: DNS/SNI
    );
    return ClientChannel(
      host,
      port: port,
      options: ChannelOptions(credentials: creds),
    );
  }

  /// (Nur Tests) Klartext-Channel.
  static ClientChannel insecure(String host, int port) {
    return ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }
}
