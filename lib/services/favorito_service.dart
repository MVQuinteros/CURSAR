import 'package:cloud_firestore/cloud_firestore.dart';

/// Favoritos del usuario, en la subcoleccion `usuarios/{uid}/favoritos`.
///
/// Los documentos se escriben con **ID determinista** derivado de la entidad
/// (`oferta_<ofertaId>` / `institucion_<institucionUid>`) en vez de con `.add()`.
/// Eso elimina los duplicados por dos vias: agregar dos veces el mismo favorito
/// sobrescribe el mismo documento, y dos toques simultaneos convergen al mismo
/// ID, sin carrera entre escrituras.
///
/// Los documentos anteriores a esto se crearon con ID automatico. Por eso antes
/// de escribir se busca en la base un favorito equivalente y, si ya existe, se
/// sale sin escribir nada: la base queda como esta y nunca se agrega un
/// duplicado. Los IDs viejos siguen siendo validos para `eliminarFavorito`.
class FavoritoService {
  static const String _prefijoOferta = 'oferta_';
  static const String _prefijoInstitucion = 'institucion_';
  static const String _tipoOferta = 'oferta';
  static const String _tipoInstitucion = 'institucion';

  CollectionReference<Map<String, dynamic>> _ref(String userUid) {
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userUid)
        .collection('favoritos');
  }

  /// Si un documento de la subcoleccion es un favorito de institucion.
  ///
  /// Reconoce el esquema actual (campo `tipo`) y el legacy, que no tenia ese
  /// campo y se distinguia solo por el prefijo del ID. Acepta el snapshot sin
  /// tipar porque algunos llamadores lo reciben de un `Stream<QuerySnapshot>`
  /// sin generic.
  static bool esFavoritoDeInstitucion(
    String docId,
    Map<String, dynamic>? data,
  ) {
    if (data == null) return false;
    if (data['tipo'] == _tipoInstitucion) return true;
    if (data['ofertaId'] != null) return false;
    return docId.startsWith(_prefijoInstitucion);
  }

  /// Guarda una carrera como favorita. No hace nada si ya estaba.
  Future<void> agregarFavorito(
    String userUid,
    String ofertaId,
    String institucionUid,
  ) async {
    if (userUid.isEmpty || ofertaId.isEmpty) return;

    final favoritos = _ref(userUid);
    final existentes = await favoritos
        .where('ofertaId', isEqualTo: ofertaId)
        .limit(1)
        .get();
    if (existentes.docs.isNotEmpty) return;

    await favoritos.doc('$_prefijoOferta$ofertaId').set({
      'tipo': _tipoOferta,
      'ofertaId': ofertaId,
      'institucionUid': institucionUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Guarda una institucion como favorita. No hace nada si ya estaba.
  Future<void> agregarFavoritoInstitucion(
    String userUid,
    String institucionUid,
  ) async {
    if (userUid.isEmpty || institucionUid.isEmpty) return;

    final favoritos = _ref(userUid);
    // El filtro por `tipo` se aplica en el cliente a proposito: combinar dos
    // `where` de igualdad pediria un indice compuesto y este proyecto no
    // versiona `firestore.indexes.json`. Los favoritos de una institucion son
    // pocos, asi que traerlos todos y descartar es barato.
    final candidatos = await favoritos
        .where('institucionUid', isEqualTo: institucionUid)
        .get();
    if (candidatos.docs.any((d) => esFavoritoDeInstitucion(d.id, d.data()))) {
      return;
    }

    await favoritos.doc('$_prefijoInstitucion$institucionUid').set({
      'tipo': _tipoInstitucion,
      'institucionUid': institucionUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarFavorito(String userUid, String docId) async {
    if (userUid.isEmpty || docId.isEmpty) return;
    await _ref(userUid).doc(docId).delete();
  }

  Stream<QuerySnapshot> favoritosStream(String userUid) {
    return _ref(userUid).snapshots();
  }
}
