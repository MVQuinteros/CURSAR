import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacion_model.dart';

class NotificacionService {
  final CollectionReference _notificaciones =
      FirebaseFirestore.instance.collection('notificaciones');

  Future<void> crearNotificacion(NotificacionModel notificacion) async {
    await _notificaciones
        .doc(notificacion.notificacionId)
        .set(notificacion.toMap());
  }

  Future<void> crear({
    required String userUid,
    required String titulo,
    required String mensaje,
    required String tipo,
    String? link,
  }) async {
    await _notificaciones.add({
      'userUid': userUid,
      'titulo': titulo,
      'mensaje': mensaje,
      'tipo': tipo,
      'link': link,
      'leido': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<NotificacionModel>> obtenerNotificacionesDeUsuario(
      String userUid) async {
    final snapshot =
        await _notificaciones.where('userUid', isEqualTo: userUid).get();
    return snapshot.docs
        .map((doc) => NotificacionModel.fromMap(
            doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> notificacionesStream(String userUid) {
    return _notificaciones.where('userUid', isEqualTo: userUid).snapshots();
  }

  Future<void> marcarComoLeido(String id) async {
    await _notificaciones.doc(id).update({'leido': true});
  }

  Future<void> marcarTodasComoLeido(String userUid) async {
    final snapshot =
        await _notificaciones.where('userUid', isEqualTo: userUid).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['leido'] == false) {
        batch.update(doc.reference, {'leido': true});
      }
    }
    await batch.commit();
  }

  Future<void> eliminarNotificacion(String id) async {
    await _notificaciones.doc(id).delete();
  }
}
