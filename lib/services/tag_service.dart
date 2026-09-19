import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tag_model.dart';

class TagService {
  final CollectionReference _tags =
      FirebaseFirestore.instance.collection('tags');

  Future<void> crearTag(TagModel tag) async {
    await _tags.doc(tag.tagId).set(tag.toMap());
  }

  Future<List<TagModel>> obtenerTags() async {
    final snapshot = await _tags.get();
    return snapshot.docs
        .map((doc) =>
            TagModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<QuerySnapshot> tagsStream() {
    return _tags.snapshots();
  }

  Future<void> eliminarTag(String id) async {
    await _tags.doc(id).delete();
  }
}
