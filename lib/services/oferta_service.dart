import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/oferta_model.dart';

class OfertaService {
  final CollectionReference _ofertas =
      FirebaseFirestore.instance.collection('ofertas');

  Future<void> crearOferta(OfertaModel oferta) async {
    await _ofertas.doc(oferta.ofertaId).set(oferta.toMap());
  }

  Future<OfertaModel?> obtenerOferta(String id) async {
    final doc = await _ofertas.doc(id).get();
    if (!doc.exists) return null;
    return OfertaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<OfertaModel>> obtenerOfertas() async {
    final snapshot = await _ofertas.get();
    return snapshot.docs
        .map((doc) =>
            OfertaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<OfertaModel>> obtenerOfertasPorInstitucion(
      String institucionUid) async {
    final snapshot =
        await _ofertas.where('institucionUid', isEqualTo: institucionUid).get();
    return snapshot.docs
        .map((doc) =>
            OfertaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> ofertasStream() {
    return _ofertas.snapshots();
  }

  Future<void> actualizarOferta(String id, Map<String, dynamic> datos) async {
    await _ofertas.doc(id).update(datos);
  }

  Future<void> eliminarOferta(String id) async {
    await _ofertas.doc(id).delete();
  }
}
