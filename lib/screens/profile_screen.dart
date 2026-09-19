import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preferencias_model.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nombre = '';
  String _apellido = '';
  String _email = '';
  PreferenciasModel _preferencias = const PreferenciasModel();
  final int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    final prefs = await PreferenciasService().obtener(user.uid);
    if (mounted) {
      setState(() {
        _nombre = doc.data()?['nombre']?.toString() ?? '';
        _apellido = doc.data()?['apellido']?.toString() ?? '';
        _email = doc.data()?['email']?.toString() ?? user.email ?? '';
        _preferencias = prefs;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  void _navegar(int index) {
    if (index == _selectedIndex) return;
    if (index == 1) {
      Navigator.pushNamed(context, '/test');
    } else {
      Navigator.pop(context);
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _abrirEditarPerfil() async {
    await Navigator.pushNamed(context, '/editar-perfil');
    await _cargarDatos();
  }

  void _abrirNotificaciones() {
    Navigator.pushNamed(context, '/notificaciones');
  }

  void _abrirAyudaSoporte() {
    Navigator.pushNamed(context, '/soporte');
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y condiciones'),
        content: const Text(
          'Al usar CursAR aceptás que tus datos se utilicen únicamente para '
          'personalizar tu experiencia de búsqueda educativa. '
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: context.colors.bgMain,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(topPadding),
            SizedBox(
              height: 62,
              width: double.infinity,
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -62),
                  child: _buildAvatar(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _mostrarNombre(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildTarjetaOpciones([
                    _OpcionFila(
                      icono: Icons.edit_outlined,
                      titulo: 'Editar perfil',
                      onTap: _abrirEditarPerfil,
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _OpcionFila(
                      icono: Icons.notifications_outlined,
                      titulo: 'Notificaciones',
                      onTap: _abrirNotificaciones,
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _OpcionFila(
                      icono: Icons.radar,
                      titulo: 'Radio de búsqueda',
                      valor: '${_preferencias.radioBusqueda} km',
                      onTap: _abrirEditarPerfil,
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildTarjetaOpciones([
                    _OpcionFila(
                      icono: Icons.help_outline,
                      titulo: 'Ayuda y soporte',
                      onTap: _abrirAyudaSoporte,
                    ),
                    Divider(height: 1, color: context.colors.borderSubtle),
                    _OpcionFila(
                      icono: Icons.description_outlined,
                      titulo: 'Términos y condiciones',
                      onTap: _mostrarTerminos,
                    ),
                  ]),
                  const SizedBox(height: 26),
                  _buildCerrarSesion(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  String _mostrarNombre() {
    final completo = '$_nombre $_apellido'.trim();
    if (completo.isNotEmpty) return completo;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    return _nombre.isNotEmpty ? _nombre : 'Usuario';
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 18, 20, 64),
      decoration: BoxDecoration(
        color: context.colors.accentPrimary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mi perfil',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gestioná tu cuenta y preferencias',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.borderSubtle,
            border: Border.all(color: Colors.white, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            size: 54,
            color: context.colors.iconNormal,
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: InkWell(
            onTap: () => _mensaje('Cambiar foto de perfil'),
            customBorder: const CircleBorder(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.accentPrimary,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaOpciones(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildCerrarSesion() {
    final error = Theme.of(context).colorScheme.error;
    return InkWell(
      onTap: _cerrarSesion,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                color: error,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItemData(Icons.home_outlined, 'Inicio'),
      _NavItemData(Icons.explore_outlined, 'Test'),
      _NavItemData(Icons.favorite_outline, 'Favoritos'),
      _NavItemData(Icons.person, 'Perfil'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => _navegar(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[i].icon,
                          color: i == _selectedIndex
                              ? context.colors.iconActive
                              : context.colors.iconNormal,
                          size: 26,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: i == _selectedIndex
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == _selectedIndex
                                ? context.colors.iconActive
                                : context.colors.iconNormal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _OpcionFila extends StatelessWidget {
  const _OpcionFila({
    required this.icono,
    required this.titulo,
    this.valor,
    this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String? valor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icono, size: 22, color: context.colors.accentPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            if (valor != null) ...[
              const SizedBox(width: 8),
              Text(
                valor!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: context.colors.iconNormal,
            ),
          ],
        ),
      ),
    );
  }
}