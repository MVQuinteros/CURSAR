import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferencias_service.dart';
import '../services/theme_controller.dart';
import '../theme/app_theme.dart';

const List<int> _opcionesRadio = [5, 10, 20, 50, 100];
const List<String> _opcionesModalidad = ['Presencial', 'Virtual', 'Mixta'];
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
  String _modalidad = 'Presencial';
  String _tipoInstitucion = 'Pública y Privada';
  bool _modoOscuro = false;
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
        _modalidad = _opcionesModalidad.contains(prefs.modalidad)
            ? prefs.modalidad
            : 'Presencial';
        _tipoInstitucion = prefs.tipoInstitucion;
        _modoOscuro = ThemeController.instance.isDark;
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
      hintStyle: const TextStyle(fontSize: 14),
      prefixIcon: Icon(icono, size: 20),
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
          title: const Text('Editar perfil'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.bgMain,
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _seccionTitulo(context, 'Datos personales'),
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
              _seccionTitulo(context, 'Preferencias de búsqueda'),
              const SizedBox(height: 4),
              Text(
                'Contanos qué estás buscando para recomendarte mejor.',
                style: TextStyle(
                    fontSize: 12, color: context.colors.textSecondary),
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
              const SizedBox(height: 24),
              _seccionTitulo(context, 'Preferencias de la app'),
              const SizedBox(height: 12),
              _buildModoOscuro(),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.accentPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      context.colors.accentPrimary.withValues(alpha: 0.4),
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

  Widget _seccionTitulo(BuildContext context, String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildModoOscuro() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.accentPrimary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.dark_mode_outlined,
            color: context.colors.accentPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'Modo oscuro',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          _modoOscuro ? 'Tema oscuro activado' : 'Tema claro activado',
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
        trailing: Switch(
          value: _modoOscuro,
          activeThumbColor: context.colors.accentPrimary,
          activeTrackColor: context.colors.accentPrimary.withValues(alpha: 0.3),
          onChanged: (v) async {
            setState(() => _modoOscuro = v);
            await ThemeController.instance.setModoOscuro(v);
          },
        ),
      ),
    );
  }
}