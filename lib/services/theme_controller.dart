import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Controla el modo claro/oscuro. Cambios persisten en `usuarios/{uid}.modoOscuro`
/// y notifican a la UI (MaterialApp) para aplicar el tema en vivo.
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  bool _isDark = false;
  bool get isDark => _isDark;

  /// Carga la preferencia guardada del usuario logueado.
  Future<void> cargar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();
      final value = doc.data()?['modoOscuro'];
      if (value is bool && value != _isDark) {
        _isDark = value;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Aplica el tema al instante y persiste la preferencia.
  Future<void> setModoOscuro(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({'modoOscuro': value}, SetOptions(merge: true));
    } catch (_) {}
  }
}