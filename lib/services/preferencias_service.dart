import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preferencias_model.dart';

class PreferenciasService {
  Future<PreferenciasModel> obtener(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (!doc.exists) return const PreferenciasModel();
    return PreferenciasModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> guardar(String uid, PreferenciasModel preferencias) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .set(preferencias.toMap(), SetOptions(merge: true));
  }
}