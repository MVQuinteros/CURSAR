import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/notificacion_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _localidadController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _aceptaTerminos = false;
  DateTime? _fechaNacimiento;

  InputDecoration _buildInputDecoration({
    required Widget prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: prefixIcon,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Seleccioná tu fecha de nacimiento',
      fieldLabelText: 'Fecha',
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  String _formatearFecha(DateTime date) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná tu fecha de nacimiento')),
      );
      return;
    }
    if (!_aceptaTerminos) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final localidad = _localidadController.text.trim();

    try {
      final credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credencial.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'rol': 'usuario',
          'ultimoLogin': FieldValue.serverTimestamp(),
          'fechaNacimiento': Timestamp.fromDate(_fechaNacimiento!),
          'localidad': localidad,
        });
        await user.updateDisplayName('$nombre $apellido');
        try {
          await NotificacionService().crear(
            userUid: user.uid,
            titulo: '¡Bienvenido/a a CursAR!',
            mensaje: 'Completá tu test vocacional y descubrí tu carrera ideal.',
            tipo: 'bienvenida',
            link: '/test',
          );
        } catch (_) {}
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_mensajeError(e.code))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      try {
        await googleSignIn.initialize(
          serverClientId: '642247955799-3k5f6fdlk5n53u64a8cop90puql0q9h0.apps.googleusercontent.com',
        );
      } catch (_) {}
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        if (!doc.exists) {
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
            'uid': user.uid,
            'nombre': user.displayName ?? '',
            'apellido': '',
            'email': user.email ?? '',
            'rol': 'usuario',
            'ultimoLogin': FieldValue.serverTimestamp(),
          });
          try {
            await NotificacionService().crear(
              userUid: user.uid,
              titulo: '¡Bienvenido/a a CursAR!',
              mensaje: 'Completá tu test vocacional y descubrí tu carrera ideal.',
              tipo: 'bienvenida',
              link: '/test',
            );
          } catch (_) {}
        }
      }
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String _mensajeError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Email inválido';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'invalid-credential':
        return 'Email o contraseña incorrectos';
      default:
        return 'Error al crear la cuenta. Intentá de nuevo.';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _localidadController.dispose();
    super.dispose();
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
            height: MediaQuery.of(context).size.height * 0.35,
            child: Image.asset(
              'assets/imagenes/fondoLogin.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
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
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/imagenes/logo.png',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
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
                              padding: const EdgeInsets.only(top: 32, left: 20, right: 20, bottom: 24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Crear cuenta',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _nombreController,
                                            textCapitalization: TextCapitalization.words,
                                            decoration: _buildInputDecoration(
                                              prefixIcon: const Icon(Icons.person_outline),
                                              hintText: 'Nombre',
                                            ),
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'Ingresá tu nombre';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _apellidoController,
                                            textCapitalization: TextCapitalization.words,
                                            decoration: _buildInputDecoration(
                                              prefixIcon: const Icon(Icons.person_outline),
                                              hintText: 'Apellido',
                                            ),
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return 'Ingresá tu apellido';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Ingresá tu correo electrónico';
                                        }
                                        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                        if (!emailRegex.hasMatch(value.trim())) {
                                          return 'Formato de email inválido';
                                        }
                                        return null;
                                      },
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
                                              _obscurePassword = !_obscurePassword;
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingresá una contraseña';
                                        }
                                        if (value.length < 6) {
                                          return 'Debe tener al menos 6 caracteres';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirm,
                                      decoration: _buildInputDecoration(
                                        prefixIcon: Image.asset(
                                          'assets/imagenes/logoContra.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        hintText: 'Confirmar contraseña',
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _obscureConfirm = !_obscureConfirm;
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Confirmá tu contraseña';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Las contraseñas no coinciden';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: _seleccionarFecha,
                                      child: AbsorbPointer(
                                        child: TextFormField(
                                          decoration: _buildInputDecoration(
                                            prefixIcon: const Icon(Icons.calendar_today),
                                            hintText: _fechaNacimiento != null
                                                ? _formatearFecha(_fechaNacimiento!)
                                                : 'Fecha de nacimiento',
                                          ),
                                          style: TextStyle(
                                            color: _fechaNacimiento != null
                                                ? context.colors.textPrimary
                                                : context.colors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _localidadController,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: _buildInputDecoration(
                                        prefixIcon: const Icon(Icons.location_on_outlined),
                                        hintText: 'Localidad',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _aceptaTerminos,
                                            activeColor: context.colors.accentPrimary,
                                            onChanged: (value) {
                                              setState(() {
                                                _aceptaTerminos = value ?? false;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Acepto los Términos y Condiciones',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _aceptaTerminos
                                                  ? context.colors.textPrimary
                                                  : context.colors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _aceptaTerminos ? _registrar : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.colors.accentPrimary,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: context.colors.borderSubtle,
                                        disabledForegroundColor: Colors.white70,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        'CREAR MI CUENTA',
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
                                        Expanded(child: Divider(color: context.colors.borderSubtle)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'o registrate con',
                                            style: TextStyle(
                                              color: context.colors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Divider(color: context.colors.borderSubtle)),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    OutlinedButton(
                                      onPressed: _loginWithGoogle,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: context.colors.bgSurface,
                                        foregroundColor: context.colors.textPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: BorderSide(color: context.colors.borderSubtle),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Image(
                                            image: AssetImage('assets/imagenes/logoGoogle.png'),
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
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '¿Ya tenés cuenta? ',
                                          style: TextStyle(
                                            color: context.colors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Text(
                                            'Iniciá sesión',
                                            style: TextStyle(
                                              color: context.colors.accentPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
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
}