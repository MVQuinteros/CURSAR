class NotificacionModel {
  final String notificacionId;
  final String userUid;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String? link;
  final bool leido;
  final DateTime? createdAt;

  NotificacionModel({
    required this.notificacionId,
    required this.userUid,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.link,
    this.leido = false,
    this.createdAt,
  });

  factory NotificacionModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificacionModel(
      notificacionId: id,
      userUid: map['userUid'] ?? '',
      titulo: map['titulo'] ?? '',
      mensaje: map['mensaje'] ?? '',
      tipo: map['tipo'] ?? '',
      link: map['link'],
      leido: map['leido'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificacionId': notificacionId,
      'userUid': userUid,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'link': link,
      'leido': leido,
      'createdAt': createdAt,
    };
  }
}
