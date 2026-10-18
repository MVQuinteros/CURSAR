import 'package:firebase_storage/firebase_storage.dart';

/// Centraliza el acceso a la foto de perfil en Firebase Storage.
class FotoPerfilService {
  FotoPerfilService._();

  /// Bucket del proyecto. Tiene que coincidir con "storage_bucket" de
  /// android/app/google-services.json y con firebase_config.dart. Si diverge,
  /// la app escribe en un bucket que no es el del proyecto y las descargas
  /// fallan con object-not-found aunque la subida parezca correcta.
  static const String bucket = 'proyecto-app-a77c8.firebasestorage.app';

  static const String _carpeta = 'profile_images';

  /// Referencia a la foto del usuario: profile_images/{uid}.jpg
  static Reference refDe(String uid) => FirebaseStorage.instanceFor(
        bucket: bucket,
      ).ref().child(_carpeta).child('$uid.jpg');

  /// Borra la foto del usuario. Ignora "object-not-found": si el objeto ya no
  /// existe, el objetivo se cumple igual y no tiene sentido romper el flujo.
  static Future<void> eliminar(String uid) async {
    try {
      await refDe(uid).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }
}
