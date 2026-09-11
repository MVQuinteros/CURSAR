class HistorialModel {
  final String docId;
  final String tipo;
  final String id;
  final String nombre;
  final String institucionUid;
  final String institucionNombre;
  final DateTime? createdAt;

  const HistorialModel({
    required this.docId,
    required this.tipo,
    required this.id,
    required this.nombre,
    this.institucionUid = '',
    this.institucionNombre = '',
    this.createdAt,
  });

  factory HistorialModel.fromMap(String docId, Map<String, dynamic> map) {
    return HistorialModel(
      docId: docId,
      tipo: map['tipo']?.toString() ?? '',
      id: map['id']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      institucionUid: map['institucionUid']?.toString() ?? '',
      institucionNombre: map['institucionNombre']?.toString() ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }
}