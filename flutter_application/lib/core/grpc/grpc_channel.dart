// lib/core/grpc/grpc_channel.dart
import 'package:grpc/grpc.dart';

/// Zentrale Stelle, um gRPC-Kanäle zu erzeugen.
class GrpcChannelFactory {
  /// TLS-Channel mit **Server-Zertifikat-Pinning**.
  ///
  /// [serverCertPem] = PEM des **MedicamService**-Zertifikats (Dev-Zertifikat).
  /// [authority]     = SNI/HTTP2 :authority (z. B. 'localhost' für Dev-Cert).
  static ClientChannel secure(
    String host,
    int port, {
    required List<int> serverCertPem,
    String? authority,
  }) {
    // gRPC-Dart: certificates=Root(s) für Trust-Store dieses Channels, authority=SNI+HTTP/2 :authority
    // https://pub.dev/documentation/grpc/latest/grpc/ChannelCredentials/ChannelCredentials.secure.html
    final creds = ChannelCredentials.secure(
      certificates: serverCertPem,
      authority: authority,
    );
    return ClientChannel(
      host,
      port: port,
      options: ChannelOptions(credentials: creds),
    );
  }

  /// (Nur für Tests) Klartext-Channel.
  static ClientChannel insecure(String host, int port) {
    return ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
  }
}
