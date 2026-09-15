import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferencias_service.dart';

const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreyText = Color(0xFF6B7280);
const Color _kGreyBorder = Color(0xFFE5E7EB);

const List<int> _opcionesRadio = [5, 10, 20, 50, 100];
const List<String> _opcionesModalidad = [
  'Presencial',
  'Online',
  'Híbrida',
  'Presencial y Online',
];
const List<String> _opcionesInstitucion = [
  'Pública',
  'Privada',
  'Pública y Privada',
];

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _localidadController = TextEditingController();

  String _email = '';
  int _radioBusqueda = 20;
  String _modalidad = 'Presencial y Online';
  String _tipoInstitucion = 'Pública y Privada';
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();

    final prefs = await PreferenciasService().obtener(user.uid);

    if (mounted) {
      setState(() {
        final datos = doc.data() ?? {};
        _nombreController.text = datos['nombre']?.toString() ?? '';
        _apellidoController.text = datos['apellido']?.toString() ?? '';
        _email = datos['email']?.toString() ?? user.email ?? '';
        _localidadController.text = prefs.localidad;
        _radioBusqueda = prefs.radioBusqueda;
        _modalidad = prefs.modalidad;
        _tipoInstitucion = prefs.tipoInstitucion;
        _cargando = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _mensaje('No se pudo identificar al usuario');
      return;
    }

    setState(() => _guardando = true);
    try {
      final nombre = _nombreController.text.trim();
      final apellido = _apellidoController.text.trim();

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set(
            {
              'nombre': nombre,
              'apellido': apellido,
              'nombreCompleto': '$nombre $apellido'.trim(),
              'localidad': _localidadController.text.trim(),
              'radioBusqueda': _radioBusqueda,
              'modalidad': _modalidad,
              'tipoInstitucion': _tipoInstitucion,
            },
            SetOptions(merge: true),
          );

      if (user.displayName != '$nombre $apellido'.trim() &&
          '$nombre $apellido'.trim().isNotEmpty) {
        await user.updateDisplayName('$nombre $apellido'.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        _mensaje('Ocurrió un error al guardar: $e');
      }
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  InputDecoration _decoration(String hint, IconData icono) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kGreyText, fontSize: 14),
      prefixIcon: Icon(icono, color: _kGreyText, size: 20),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kGreyBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kGreyBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kViolet, width: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _localidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _kViolet,
          foregroundColor: Colors.white,
          title: const Text('Editar perfil'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: _kViolet,
        foregroundColor: Colors.white,
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _seccionTitulo('Datos personales'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('Nombre', Icons.person_outline),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Ingresá tu nombre'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidoController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration('Apellido', Icons.person_outline),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Ingresá tu apellido'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _email,
                readOnly: true,
                decoration: _decoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 24),
              _seccionTitulo('Preferencias de búsqueda'),
              const SizedBox(height: 4),
              const Text(
                'Contanos qué estás buscando para recomendarte mejor.',
                style: TextStyle(fontSize: 12, color: _kGreyText),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _localidadController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  'Ubicación',
                  Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _radioBusqueda,
                decoration: _decoration(
                  'Radio de búsqueda',
                  Icons.radar,
                ),
                items: _opcionesRadio
                    .map((km) => DropdownMenuItem(
                          value: km,
                          child: Text('$km km'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _radioBusqueda = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _modalidad,
                decoration: _decoration(
                  'Modalidad',
                  Icons.school_outlined,
                ),
                items: _opcionesModalidad
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _modalidad = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipoInstitucion,
                decoration: _decoration(
                  'Tipo de institución',
                  Icons.account_balance_outlined,
                ),
                items: _opcionesInstitucion
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoInstitucion = value);
                  }
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kViolet,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _kViolet.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccionTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }
}