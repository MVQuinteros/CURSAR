import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reporte_model.dart';

class SoporteService {
  static const String _coleccion = 'soporte';

  Future<void> enviarReporte(ReporteModel reporte) async {
    final mapa = reporte.toMap();
    mapa['createdAt'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance.collection(_coleccion).add(mapa);
  }

  /// Historial de reportes del usuario, más recientes primero.
  ///
  /// Stream para que la pantalla se actualice sola cuando un administrador
  /// cambia el estado o responde un reporte.
  Stream<List<ReporteModel>> getReportesUsuario(String uid) {
    return FirebaseFirestore.instance
        .collection(_coleccion)
        .where('userUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ReporteModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Misma consulta que [getReportesUsuario] pero devolviendo solo el total,
  /// para el badge de la pantalla de ayuda.
  Stream<int> contarReportesUsuario(String uid) {
    return getReportesUsuario(uid).map((reportes) => reportes.length);
  }
}
