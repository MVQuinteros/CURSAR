class ReporteModel {
  final String? uid;
  final String email;
  final String tipo;
  final String mensaje;
  final DateTime? createdAt;

  const ReporteModel({
    this.uid,
    required this.email,
    required this.tipo,
    required this.mensaje,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      'email': email,
      'tipo': tipo,
      'mensaje': mensaje,
      'createdAt': createdAt,
    };
  }
}