class TagModel {
  final String tagId;
  final String nombre;
  final String descripcion;

  TagModel({
    required this.tagId,
    required this.nombre,
    required this.descripcion,
  });

  factory TagModel.fromMap(String id, Map<String, dynamic> map) {
    return TagModel(
      tagId: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tagId': tagId,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
