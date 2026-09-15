import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreyText = Color(0xFF6B7280);

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  bool _notificaciones = true;
  bool _ubicacionAutomatica = false;
  bool _modoOscuro = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (mounted) {
      final datos = doc.data() ?? {};
      setState(() {
        _notificaciones = datos['notificaciones'] ?? true;
        _ubicacionAutomatica = datos['ubicacionAutomatica'] ?? false;
        _modoOscuro = datos['modoOscuro'] ?? false;
        _cargando = false;
      });
    }
  }

  Future<void> _guardarCampo(String campo, Object valor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .set({campo: valor}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _kViolet,
          foregroundColor: Colors.white,
          title: const Text('Configuración'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: _kViolet,
        foregroundColor: Colors.white,
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _titulo('General'),
          _opcionSwitch(
            icon: Icons.notifications_outlined,
            color: const Color(0xFF3B82F6),
            bg: const Color(0xFFEAF3FF),
            titulo: 'Notificaciones',
            subtitulo: 'Recibir avisos de novedades',
            valor: _notificaciones,
            onChanged: (v) {
              setState(() => _notificaciones = v);
              _guardarCampo('notificaciones', v);
              _mensaje(v ? 'Notificaciones activadas' : 'Notificaciones desactivadas');
            },
          ),
          _opcionSwitch(
            icon: Icons.my_location,
            color: const Color(0xFF2FA36B),
            bg: const Color(0xFFE5F9EF),
            titulo: 'Usar mi ubicación automática',
            subtitulo: 'Centrar el mapa en tu ubicación',
            valor: _ubicacionAutomatica,
            onChanged: (v) {
              setState(() => _ubicacionAutomatica = v);
              _guardarCampo('ubicacionAutomatica', v);
            },
          ),
          _opcionSwitch(
            icon: Icons.dark_mode_outlined,
            color: _kViolet,
            bg: const Color(0xFFF0ECFF),
            titulo: 'Modo oscuro',
            subtitulo: 'Próximamente disponible',
            valor: _modoOscuro,
            onChanged: (v) {
              setState(() => _modoOscuro = v);
              _guardarCampo('modoOscuro', v);
              _mensaje('El modo oscuro estará disponible pronto');
            },
          ),
          const SizedBox(height: 24),
          _titulo('Acerca de'),
          _opcionTexto(
            icon: Icons.info_outline,
            color: const Color(0xFFEC4899),
            bg: const Color(0xFFFCE7F3),
            titulo: 'Versión de la app',
            subtitulo: '1.0.0',
          ),
          _opcionTexto(
            icon: Icons.policy_outlined,
            color: const Color(0xFF64748B),
            bg: const Color(0xFFF1F5F9),
            titulo: 'Política de privacidad',
            subtitulo: 'Conocé cómo usamos tus datos',
            onTap: _mostrarPrivacidad,
          ),
        ],
      ),
    );
  }

  void _mostrarPrivacidad() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de privacidad'),
        content: const Text(
          'Tus datos se guardan de forma segura en Firebase y se usan '
          'únicamente para personalizar tu experiencia en CursAR. '
          'No compartimos tu información con terceros.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  Widget _titulo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _kGreyText,
        ),
      ),
    );
  }

  Widget _opcionSwitch({
    required IconData icon,
    required Color color,
    required Color bg,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(fontSize: 12, color: _kGreyText),
        ),
        trailing: Switch(
          value: valor,
          activeThumbColor: _kViolet,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _opcionTexto({
    required IconData icon,
    required Color color,
    required Color bg,
    required String titulo,
    required String subtitulo,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(fontSize: 12, color: _kGreyText),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF))
            : null,
        onTap: onTap,
      ),
    );
  }
}