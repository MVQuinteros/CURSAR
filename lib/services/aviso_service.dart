import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/aviso_model.dart';

class AvisoService {
  final CollectionReference _avisos =
      FirebaseFirestore.instance.collection('avisos');

  Stream<QuerySnapshot> avisosStream() {
    return _avisos.snapshots();
  }

  Future<List<AvisoModel>> obtenerAvisos() async {
    final snapshot = await _avisos.get();
    return snapshot.docs
        .map((doc) =>
            AvisoModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> crearAviso(AvisoModel aviso) async {
    await _avisos.doc(aviso.avisoId).set(aviso.toMap());
  }

  Future<void> marcarAvisoLeido(String userUid, String avisoId) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .update({
      'avisosLeidos': FieldValue.arrayUnion([avisoId]),
    });
  }

  Future<void> marcarTodosAvisosLeidos(
      String userUid, List<String> avisoIds) async {
    if (avisoIds.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .update({
      'avisosLeidos': FieldValue.arrayUnion(avisoIds),
    });
  }

  Future<List<String>> obtenerAvisosLeidos(String userUid) async {
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .get();
    final data = doc.data();
    if (data == null) return [];
    final leidos = data['avisosLeidos'];
    if (leidos is! List) return [];
    return leidos.map((e) => e.toString()).toList();
  }
}