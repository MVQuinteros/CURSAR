import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritoService {
  Future<void> agregarFavorito(
      String userUid, String ofertaId, String institucionUid) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .collection('favoritos')
        .add({
      'ofertaId': ofertaId,
      'institucionUid': institucionUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarFavorito(String userUid, String docId) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .collection('favoritos')
        .doc(docId)
        .delete();
  }

  Stream<QuerySnapshot> favoritosStream(String userUid) {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .collection('favoritos')
        .snapshots();
  }
}
