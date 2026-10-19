import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reporte_model.dart';

class SoporteService {
  Future<void> enviarReporte(ReporteModel reporte) async {
    final mapa = reporte.toMap();
    mapa['createdAt'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance.collection('soporte').add(mapa);
  }

  /// Los reportes que envió [uid], del más nuevo al más viejo.
  ///
  /// Filtra solo por `uid` (la regla de lectura exige que la consulta incluya
  /// esa condición) y ordena en memoria, así no hace falta un índice compuesto.
  Stream<List<ReporteModel>> misReportes(String uid) {
    return FirebaseFirestore.instance
        .collection('soporte')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final reportes = snapshot.docs
          .map((doc) => ReporteModel.fromMap(doc.id, doc.data()))
          .toList();
      reportes.sort((a, b) {
        final fechaA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final fechaB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return fechaB.compareTo(fechaA);
      });
      return reportes;
    });
  }
}
