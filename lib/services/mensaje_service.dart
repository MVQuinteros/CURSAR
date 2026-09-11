import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mensaje_model.dart';

class MensajeService {
  final CollectionReference _mensajes =
      FirebaseFirestore.instance.collection('mensajes');

  Future<void> crearMensaje(MensajeModel mensaje) async {
    await _mensajes.doc(mensaje.mensajeId).set(mensaje.toMap());
  }

  Future<MensajeModel?> obtenerMensaje(String id) async {
    final doc = await _mensajes.doc(id).get();
    if (!doc.exists) return null;
    return MensajeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<MensajeModel>> obtenerMensajesDeUsuario(String userUid) async {
    final snapshot =
        await _mensajes.where('userUid', isEqualTo: userUid).get();
    return snapshot.docs
        .map((doc) =>
            MensajeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> mensajesStream(String userUid) {
    return _mensajes.where('userUid', isEqualTo: userUid).snapshots();
  }

  Future<void> marcarComoLeido(String id) async {
    await _mensajes.doc(id).update({'leido': true});
  }

  Future<void> eliminarMensaje(String id) async {
    await _mensajes.doc(id).delete();
  }
}
