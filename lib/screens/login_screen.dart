import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  static const Color _darkNavy = Color(0xFF001533);

  InputDecoration _buildInputDecoration({
    required Widget prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14),
      prefixIcon: Padding(padding: const EdgeInsets.all(12), child: prefixIcon),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá todos los campos')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_mensajeError(e.code))));
      }
    }
  }

  String _mensajeError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No hay usuario registrado con ese email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-credential':
        return 'Email o contraseña incorrectos';
      default:
        return 'Error al iniciar sesión. Intentá de nuevo.';
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      try {
        await googleSignIn.initialize(
          serverClientId:
              '642247955799-3k5f6fdlk5n53u64a8cop90puql0q9h0.apps.googleusercontent.com',
        );
      } catch (_) {}
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'nombre': user.displayName ?? '',
                'apellido': '',
                'email': user.email ?? '',
                'rol': 'usuario',
                'ultimoLogin': FieldValue.serverTimestamp(),
              });
        }
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(
              'assets/imagenes/fondoLogin.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(
                                  'assets/imagenes/logo.png',
                                  height: 140,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 40),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            _darkNavy.withValues(alpha: 0.8),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Tu futuro académico',
                                          style: TextStyle(
                                            color: context.colors.accentPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' en un solo lugar',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: context.colors.bgSurface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 40,
                                left: 24,
                                right: 24,
                                bottom: 24,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _buildInputDecoration(
                                      prefixIcon: Image.asset(
                                        'assets/imagenes/logoCorreo.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      hintText: 'Correo electrónico',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: _buildInputDecoration(
                                      prefixIcon: Image.asset(
                                        'assets/imagenes/logoContra.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      hintText: 'Contraseña',
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Image.asset(
                                            'assets/imagenes/iconoOjo.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                        context,
                                        '/forgot-password',
                                      ),
                                      child: Text(
                                        '¿Olvidaste tu contraseña?',
                                        style: TextStyle(
                                          color: context.colors.accentPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loginWithEmail,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          context.colors.accentPrimary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: const Text(
                                      'INICIAR SESIÓN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                            color: context.colors.borderSubtle),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          'o continuá con',
                                          style: TextStyle(
                                            color: context.colors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                            color: context.colors.borderSubtle),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  OutlinedButton(
                                    onPressed: _loginWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: context.colors.bgSurface,
                                      foregroundColor: context.colors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      side: BorderSide(
                                        color: context.colors.borderSubtle,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Image(
                                          image: AssetImage(
                                            'assets/imagenes/logoGoogle.png',
                                          ),
                                          height: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Continuar con Google',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: context.colors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¿No tenés cuenta? ',
                                        style: TextStyle(
                                          color: context.colors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => Navigator.pushNamed(
                                          context,
                                          '/register',
                                        ),
                                        child: Text(
                                          'Registrate',
                                          style: TextStyle(
                                            color: context.colors.accentPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}