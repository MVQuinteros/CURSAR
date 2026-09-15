import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/historial_model.dart';

class HistorialService {
  Future<void> registrar({
    required String uid,
    required String tipo,
    required String id,
    required String nombre,
    String institucionUid = '',
    String institucionNombre = '',
  }) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('historial')
        .add({
      'tipo': tipo,
      'id': id,
      'nombre': nombre,
      'institucionUid': institucionUid,
      'institucionNombre': institucionNombre,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<HistorialModel>> historialStream(String uid, {String? tipo}) {
    Query query = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('historial')
        .orderBy('createdAt', descending: true)
        .limit(50);
    if (tipo != null) {
      query = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('historial')
          .where('tipo', isEqualTo: tipo)
          .orderBy('createdAt', descending: true)
          .limit(50);
    }
    return query.snapshots().map(
        (snap) => snap.docs
            .map((doc) =>
                HistorialModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}