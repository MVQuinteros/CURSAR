import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/preferencias_model.dart';
import '../services/preferencias_service.dart';
import '../theme/app_theme.dart';

const Color _kRose = Color(0xFFFF6B95);
const Color _kViolet = Color(0xFF8B5CF6);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _nombre = '';
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
        _nombre = doc.data()?['nombre'] ?? '';
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

  void _abrirConfiguracion() {
    Navigator.pushNamed(context, '/configuracion');
  }

  void _abrirHistorial() {
    Navigator.pushNamed(context, '/historial');
  }

  void _abrirCarrerasVistas() {
    Navigator.pushNamed(
      context,
      '/historial',
      arguments: {'titulo': 'Carreras vistas', 'tipo': 'carrera'},
    );
  }

  void _abrirAyudaSoporte() {
    Navigator.pushNamed(context, '/soporte');
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  Text(
                    _nombre.isNotEmpty ? 'Hola, $_nombre 👋' : 'Hola 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explorá tu próximo paso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15, color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  _buildBotonPerfil(),
                  const SizedBox(height: 28),
                  _PreferenciasCard(
                    ubicacion: _preferencias.localidad,
                    radio: '${_preferencias.radioBusqueda} km',
                    modalidad: _preferencias.modalidad,
                    tipoInstitucion: _preferencias.tipoInstitucion,
                    onEditar: _abrirEditarPerfil,
                  ),
                  const SizedBox(height: 16),
                  _ActividadCard(
                    onBusquedasRecientes: _abrirHistorial,
                    onCarrerasVistas: _abrirCarrerasVistas,
                  ),
                  const SizedBox(height: 16),
                  _MasCard(
                    onConfiguracion: _abrirConfiguracion,
                    onAyudaSoporte: _abrirAyudaSoporte,
                  ),
                  const SizedBox(height: 24),
                  _buildCerrarSesion(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(double topPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B95), Color(0xFFFF9A62), Color(0xFFFFC85C)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _BlobPainter())),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: _abrirConfiguracion,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kRose, _kViolet],
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: CircleAvatar(
              backgroundColor: context.colors.bgSurface,
              child: const Icon(
                Icons.person,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              onTap: () => _mensaje('Cambiar foto de perfil'),
              customBorder: const CircleBorder(),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_kRose, _kViolet],
                  ),
                  border: Border.fromBorderSide(BorderSide(color: Colors.white)),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonPerfil() {
    return InkWell(
      onTap: _abrirEditarPerfil,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined,
                color: context.colors.accentPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Editar perfil',
              style: TextStyle(
                color: context.colors.accentPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCerrarSesion() {
    final error = Theme.of(context).colorScheme.error;
    return InkWell(
      onTap: _cerrarSesion,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
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

class _BlobPainter extends CustomPainter {
  const _BlobPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white.withValues(alpha: 0.14);
    canvas.drawCircle(Offset(size.width - 40, 34), 90, paint);
    paint.color = Colors.white.withValues(alpha: 0.10);
    canvas.drawCircle(Offset(size.width * 0.22, size.height - 30), 70, paint);
    paint.color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(Offset(size.width * 0.62, size.height - 56), 46, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Card extends StatelessWidget {
  const _Card({required this.titulo, this.trailing, required this.children});

  final String titulo;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _PreferenciasCard extends StatelessWidget {
  const _PreferenciasCard({
    required this.ubicacion,
    required this.radio,
    required this.modalidad,
    required this.tipoInstitucion,
    required this.onEditar,
  });

  final String ubicacion;
  final String radio;
  final String modalidad;
  final String tipoInstitucion;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return _Card(
      titulo: 'Preferencias de búsqueda',
      trailing: TextButton(
        onPressed: onEditar,
        style: TextButton.styleFrom(
          foregroundColor: context.colors.accentPrimary,
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Editar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      children: [
        _FilaPreferencia(
          icon: Icons.location_on,
          color: context.colors.accentPrimary,
          titulo: 'Ubicación',
          valor: ubicacion.isNotEmpty
              ? ubicacion
              : 'San Miguel, Buenos Aires',
        ),
        _FilaPreferencia(
          icon: Icons.radar,
          color: const Color(0xFF2FA36B),
          titulo: 'Radio de búsqueda',
          valor: radio,
        ),
        _FilaPreferencia(
          icon: Icons.school_outlined,
          color: const Color(0xFFF59E0B),
          titulo: 'Modalidad',
          valor: modalidad,
        ),
        _FilaPreferencia(
          icon: Icons.account_balance_outlined,
          color: context.colors.accentPrimary,
          titulo: 'Tipo de institución',
          valor: tipoInstitucion,
        ),
      ],
    );
  }
}

class _FilaPreferencia extends StatelessWidget {
  const _FilaPreferencia({
    required this.icon,
    required this.color,
    required this.titulo,
    required this.valor,
  });

  final IconData icon;
  final Color color;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                  fontSize: 14, color: context.colors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActividadCard extends StatelessWidget {
  const _ActividadCard({
    required this.onBusquedasRecientes,
    required this.onCarrerasVistas,
  });

  final VoidCallback onBusquedasRecientes;
  final VoidCallback onCarrerasVistas;

  @override
  Widget build(BuildContext context) {
    return _Card(
      titulo: 'Actividad',
      children: [
        _FilaOpcion(
          icon: Icons.history,
          color: const Color(0xFF6366F1),
          titulo: 'Búsquedas recientes',
          onTap: onBusquedasRecientes,
        ),
        Divider(height: 1, color: context.colors.borderSubtle),
        _FilaOpcion(
          icon: Icons.auto_stories_outlined,
          color: const Color(0xFFEC4899),
          titulo: 'Carreras vistas',
          onTap: onCarrerasVistas,
        ),
      ],
    );
  }
}

class _MasCard extends StatelessWidget {
  const _MasCard({
    required this.onConfiguracion,
    required this.onAyudaSoporte,
  });

  final VoidCallback onConfiguracion;
  final VoidCallback onAyudaSoporte;

  @override
  Widget build(BuildContext context) {
    return _Card(
      titulo: 'Más',
      children: [
        _FilaOpcion(
          icon: Icons.settings_outlined,
          color: context.colors.accentPrimary,
          titulo: 'Configuración',
          onTap: onConfiguracion,
        ),
        Divider(height: 1, color: context.colors.borderSubtle),
        _FilaOpcion(
          icon: Icons.help_outline,
          color: context.colors.iconNormal,
          titulo: 'Ayuda y soporte',
          onTap: onAyudaSoporte,
        ),
      ],
    );
  }
}

class _FilaOpcion extends StatelessWidget {
  const _FilaOpcion({
    required this.icon,
    required this.color,
    required this.titulo,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String titulo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                    fontSize: 14, color: context.colors.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.iconNormal),
          ],
        ),
      ),
    );
  }
}