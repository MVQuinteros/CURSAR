import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Error de inicio de sesión con Google con un mensaje listo para mostrar
/// al usuario.
class GoogleAuthException implements Exception {
  GoogleAuthException(this.mensaje, {this.cancelado = false});

  /// Mensaje en español para mostrar en pantalla.
  final String mensaje;

  /// `true` cuando el usuario cerró el selector de cuentas por su cuenta.
  /// En ese caso conviene no mostrar un error.
  final bool cancelado;

  @override
  String toString() => mensaje;
}

/// Centraliza la configuración de Google Sign-In para inicializar el plugin
/// una sola vez y devolver errores con mensajes claros.
class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  /// Client ID del tipo "Web" del proyecto Firebase.
  static const String _serverClientId =
      '642247955799-3k5f6fdlk5n53u64a8cop90puql0q9h0.apps.googleusercontent.com';

  Future<void>? _initFuture;

  /// Inicializa el plugin una única vez y reutiliza el resultado.
  Future<void> _ensureInitialized() {
    return _initFuture ??= GoogleSignIn.instance.initialize(
      serverClientId: _serverClientId,
    );
  }

  /// Abre el selector de cuentas de Google y autentica contra Firebase.
  ///
  /// Lanza [GoogleAuthException] con un mensaje en español si algo falla.
  Future<UserCredential> iniciarSesion() async {
    try {
      await _ensureInitialized();

      final GoogleSignInAccount cuenta = await GoogleSignIn.instance
          .authenticate();
      final String? idToken = cuenta.authentication.idToken;
      if (idToken == null) {
        throw GoogleAuthException(
          'Google no devolvió un token de identidad válido. Intentá de nuevo.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      throw GoogleAuthException(_mensajeGoogle(e), cancelado: _esCancelado(e));
    } on FirebaseAuthException catch (e) {
      throw GoogleAuthException(_mensajeFirebase(e));
    } on GoogleAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error inesperado en iniciarSesion(): $e');
      throw GoogleAuthException(
        'No se pudo iniciar sesión con Google. Intentá de nuevo.',
      );
    }
  }

  bool _esCancelado(GoogleSignInException e) {
    return e.code == GoogleSignInExceptionCode.canceled ||
        e.code == GoogleSignInExceptionCode.interrupted;
  }

  String _mensajeGoogle(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Inicio de sesión cancelado.';
      case GoogleSignInExceptionCode.interrupted:
        return 'El inicio de sesión se interrumpió. Intentá de nuevo.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'No se pudo mostrar el selector de cuentas de Google.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'La configuración de Google Sign-In no es válida. '
            'Revisá que el SHA-1 de la app esté registrado en Firebase.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'La cuenta de Google no coincide con el usuario actual.';
      case GoogleSignInExceptionCode.unknownError:
        final detalle = e.description ?? e.details?.toString();
        return detalle == null
            ? 'No se pudo iniciar sesión con Google. Intentá de nuevo.'
            : 'No se pudo iniciar sesión con Google: $detalle';
    }
  }

  String _mensajeFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con ese email usando otro método de ingreso.';
      case 'invalid-credential':
        return 'La credencial de Google no es válida. Intentá de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisá tu red e intentá de nuevo.';
      case 'operation-not-allowed':
        return 'El ingreso con Google está deshabilitado en Firebase.';
      default:
        return 'No se pudo iniciar sesión con Google (${e.code}).';
    }
  }
}
