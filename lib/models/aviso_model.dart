class AvisoModel {
  final String avisoId;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String? link;
  final DateTime? publicado;

  AvisoModel({
    required this.avisoId,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    this.link,
    this.publicado,
  });

  factory AvisoModel.fromMap(String id, Map<String, dynamic> map) {
    return AvisoModel(
      avisoId: id,
      titulo: map['titulo'] ?? '',
      mensaje: map['mensaje'] ?? '',
      tipo: map['tipo'] ?? '',
      link: map['link'],
      publicado: (map['publicado'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'avisoId': avisoId,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'link': link,
      'publicado': publicado,
    };
  }
}