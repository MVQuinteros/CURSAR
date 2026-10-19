import 'package:cloud_firestore/cloud_firestore.dart';

class ReporteModel {
  final String? id;
  final String? uid;
  final String email;
  final String tipo;
  final String mensaje;

  /// Respuesta del equipo de soporte. La escribe el panel; hasta entonces queda
  /// nula.
  final String? respuesta;

  /// `nuevo` o `resuelto` (el panel lo cambia al responder o al reabrir).
  final String estado;

  final DateTime? createdAt;

  const ReporteModel({
    this.id,
    this.uid,
    required this.email,
    required this.tipo,
    required this.mensaje,
    this.respuesta,
    this.estado = 'nuevo',
    this.createdAt,
  });

  bool get resuelto => estado == 'resuelto';

  /// Para el listado de "Mis reportes". Los reportes viejos no tienen `estado`
  /// ni `respuesta`, así que se completan con valores por defecto.
  factory ReporteModel.fromMap(String id, Map<String, dynamic> map) {
    final respuesta = '${map['respuesta'] ?? ''}'.trim();
    final creado = map['createdAt'];
    return ReporteModel(
      id: id,
      uid: '${map['uid'] ?? ''}'.trim(),
      email: '${map['email'] ?? ''}'.trim(),
      tipo: '${map['tipo'] ?? 'Consulta'}'.trim(),
      mensaje: '${map['mensaje'] ?? ''}'.trim(),
      respuesta: respuesta.isEmpty ? null : respuesta,
      estado: '${map['estado'] ?? (respuesta.isEmpty ? 'nuevo' : 'resuelto')}'
          .trim(),
      createdAt: creado is Timestamp ? creado.toDate() : null,
    );
  }

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
