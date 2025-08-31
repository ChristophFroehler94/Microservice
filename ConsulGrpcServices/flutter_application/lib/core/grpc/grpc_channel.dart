import 'package:grpc/grpc.dart';

/// Zentrale Stelle, um gRPC-Kanäle zu erzeugen.
class GrpcChannelFactory {
  /// TLS-Channel mit eigener Root-CA.
  ///
  /// [caPem]    = Bytes deiner Root-CA (z. B. consul-agent-ca.pem).
  /// [authority]= Optionaler SNI/Hostname-Override, falls du via IP verbindest,
  ///             dein Serverzertifikat aber nur einen Hostnamen hat.
  static ClientChannel secure(
    String host,
    int port, {
    required List<int> caPem,
    String? authority,
  }) {
    return ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: ChannelCredentials.secure(
          certificates: caPem,
          authority: authority,
        ),
      ),
    );
  }

  /// (Nur für Tests) Klartext-Channel.
  static ClientChannel insecure(String host, int port) {
    return ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
  }
}
