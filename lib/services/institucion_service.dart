import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/institucion_model.dart';

class InstitucionService {
  final CollectionReference _instituciones =
      FirebaseFirestore.instance.collection('instituciones');

  Future<void> crearInstitucion(InstitucionModel institucion) async {
    await _instituciones
        .doc(institucion.institucionUid)
        .set(institucion.toMap());
  }

  Future<InstitucionModel?> obtenerInstitucion(String uid) async {
    final doc = await _instituciones.doc(uid).get();
    if (!doc.exists) return null;
    return InstitucionModel.fromMap(
        doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<InstitucionModel>> obtenerTodas() async {
    final snapshot = await _instituciones.get();
    return snapshot.docs
        .map((doc) =>
            InstitucionModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> institucionesStream() {
    return _instituciones.snapshots();
  }

  Future<void> actualizarInstitucion(
      String uid, Map<String, dynamic> datos) async {
    await _instituciones.doc(uid).update(datos);
  }

  Future<void> eliminarInstitucion(String uid) async {
    await _instituciones.doc(uid).delete();
  }
}
