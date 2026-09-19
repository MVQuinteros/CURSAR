class MensajeModel {
  final String mensajeId;
  final String userUid;
  final String institucionUid;
  final String contenido;
  final bool leido;
  final DateTime? createdAt;

  MensajeModel({
    required this.mensajeId,
    required this.userUid,
    required this.institucionUid,
    required this.contenido,
    this.leido = false,
    this.createdAt,
  });

  factory MensajeModel.fromMap(String id, Map<String, dynamic> map) {
    return MensajeModel(
      mensajeId: id,
      userUid: map['userUid'] ?? '',
      institucionUid: map['institucionUid'] ?? '',
      contenido: map['contenido'] ?? '',
      leido: map['leido'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mensajeId': mensajeId,
      'userUid': userUid,
      'institucionUid': institucionUid,
      'contenido': contenido,
      'leido': leido,
      'createdAt': createdAt,
    };
  }
}
