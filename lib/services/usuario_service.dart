import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsuarioService {
  final CollectionReference _usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  Future<void> crearUsuario(UserModel usuario) async {
    await _usuarios.doc(usuario.uid).set(usuario.toMap());
  }

  Future<UserModel?> obtenerUsuario(String uid) async {
    final doc = await _usuarios.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<void> actualizarUsuario(String uid, Map<String, dynamic> datos) async {
    await _usuarios.doc(uid).update(datos);
  }

  Future<void> eliminarUsuario(String uid) async {
    await _usuarios.doc(uid).delete();
  }

  Stream<DocumentSnapshot> usuarioStream(String uid) {
    return _usuarios.doc(uid).snapshots();
  }
}
