class ReporteModel {
  final String? id;

  /// ID del usuario autenticado. Coincide con el campo que exigen las
  /// reglas de seguridad de la colección 'soporte'.
  final String? userUid;
  final String email;
  final String tipo;
  final String mensaje;
  /// Estado del reporte: 'pendiente', 'en_revision' o 'respondido'.
  final String estado;
  /// Respuesta del administrador. Solo tiene sentido cuando el estado
  /// es 'respondido', pero se muestra siempre que exista.
  final String? respuestaAdmin;
  final DateTime? createdAt;

  const ReporteModel({
    this.id,
    this.userUid,
    required this.email,
    required this.tipo,
    required this.mensaje,
    this.estado = 'pendiente',
    this.respuestaAdmin,
    this.createdAt,
  });

  /// Lee un documento de la colección 'soporte'. Tolera documentos viejos
  /// que no tengan los campos nuevos (estado/respuestaAdmin).
  factory ReporteModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ReporteModel(
      id: id,
      userUid: data['userUid'] as String?,
      email: (data['email'] as String?) ?? '',
      tipo: (data['tipo'] as String?) ?? 'Problema',
      mensaje: (data['mensaje'] as String?) ?? '',
      estado: (data['estado'] as String?) ?? 'pendiente',
      respuestaAdmin: data['respuestaAdmin'] as String?,
      // Firestore devuelve Timestamp; el patrón del proyecto es toDate().
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (userUid != null) 'userUid': userUid,
      'email': email,
      'tipo': tipo,
      'mensaje': mensaje,
      'estado': estado,
      if (respuestaAdmin != null) 'respuestaAdmin': respuestaAdmin,
      'createdAt': createdAt,
    };
  }
}
