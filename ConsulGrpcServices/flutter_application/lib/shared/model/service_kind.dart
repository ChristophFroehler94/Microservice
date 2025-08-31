/// Typ des angeschlossenen Dienstes. Bestimmt, welche UI/Actions aktiv sind.
enum ServiceKind { camera, polflash }

extension ServiceKindLabel on ServiceKind {
  String get label => this == ServiceKind.camera ? 'Camera' : 'PolFlash';
}