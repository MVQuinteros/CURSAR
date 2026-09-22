import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'models/institucion_model.dart';
import 'models/aviso_model.dart';
import 'services/aviso_service.dart';
import 'services/notificacion_service.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = 'Usuario';
  Position? _userPosition;
  List<InstitucionModel>? _institucionesCache;
  Set<String>? _avisosLeidos;

  @override
  void initState() {
    super.initState();
    ThemeController.instance.cargar();
    _cargarNombreUsuario();
    _cargarUbicacion();
    _recargarAvisosLeidos();
  }

  Future<void> _recargarAvisosLeidos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final leidos = await AvisoService().obtenerAvisosLeidos(uid);
    if (mounted) {
      setState(() => _avisosLeidos = leidos.toSet());
    }
  }

  Widget _campanaNotificaciones() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return StreamBuilder<QuerySnapshot>(
      stream: AvisoService().avisosStream(),
      builder: (context, avisoSnap) {
        final cantidadAvisos = avisoSnap.data?.docs.length ?? 0;
        final leidosAvisos = _avisosLeidos == null
            ? 0
            : (_avisosLeidos!.length < cantidadAvisos
                  ? cantidadAvisos - _avisosLeidos!.length
                  : 0);
        return StreamBuilder<QuerySnapshot>(
          stream: NotificacionService().notificacionesStream(uid),
          builder: (context, notifSnap) {
            final docs = notifSnap.data?.docs ?? [];
            var noLeidas = 0;
            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['leido'] == false) noLeidas++;
            }
            final total = noLeidas + leidosAvisos;
            return Badge(
              isLabelVisible: total > 0,
              backgroundColor: const Color(0xFFE53935),
              label: Text('$total'),
              child: IconButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notificaciones');
                  await _recargarAvisosLeidos();
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: Colors.blue.shade900,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cargarUbicacion() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) _mostrarDialogoPermisoUbicacion();
        return;
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() => _userPosition = pos);
      }
    } catch (_) {}
  }

  void _mostrarDialogoPermisoUbicacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de ubicación'),
        content: const Text(
          'Para mostrarte tu ubicación en el mapa, necesitamos acceso a tu ubicación. '
          'Por favor, activá el permiso desde la configuración de la app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accentPrimary,
            ),
            child: const Text(
              'Abrir configuración',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      setState(() => _userName = user.displayName!);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      final nombre = doc.data()?['nombre'] ?? '';
      final apellido = doc.data()?['apellido'] ?? '';
      final completo = '$nombre $apellido'.trim();
      if (completo.isNotEmpty) {
        setState(() => _userName = completo);
      }
    }
  }

  Widget _cardAviso(AvisoModel aviso) {
    final color = _colorPorTipo(aviso.tipo);
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (aviso.link != null && aviso.link!.isNotEmpty) {
              _abrirLink(aviso.link!);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(
                      _iconoPorTipo(aviso.tipo),
                      color: color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aviso.titulo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: context.colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatearFechaAviso(aviso.publicado),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                aviso.mensaje,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<InstitucionModel>> _cargarInstituciones() async {
    if (_institucionesCache != null) return _institucionesCache!;
    final snapshot = await FirebaseFirestore.instance
        .collection('instituciones')
        .get();
    _institucionesCache = snapshot.docs
        .map((doc) => InstitucionModel.fromMap(doc.id, doc.data()))
        .toList();
    return _institucionesCache!;
  }

  Future<void> _abrirLink(String link) async {
    await Navigator.pushNamed(context, link);
  }

  String _formatearFechaAviso(DateTime? fecha) {
    if (fecha == null) return '';
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final hoy = DateTime.now();
    final diff = hoy.difference(fecha).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'inscripcion':
        return Icons.event_available;
      case 'noticia':
        return Icons.newspaper;
      case 'consejo':
        return Icons.tips_and_updates;
      case 'bienvenida':
        return Icons.celebration;
      case 'test':
        return Icons.school;
      default:
        return Icons.notifications;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'inscripcion':
        return const Color(0xFF2E7D32);
      case 'noticia':
        return const Color(0xFF1565C0);
      case 'consejo':
        return const Color(0xFFF9A825);
      case 'bienvenida':
        return const Color(0xFF6A1B9A);
      default:
        return context.colors.accentPrimary;
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/test');
      return;
    }
    if (index == 2) {
      Navigator.pushNamed(context, '/favoritos');
      return;
    }
    if (index == 3) {
      Navigator.pushNamed(context, '/profile');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/imagenes/fondo2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Image.asset(
                              'assets/imagenes/logo3.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          _campanaNotificaciones(),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola, $_userName!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Descubrí tu camino y empezá a construir tu futuro.',
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: context.colors.bgSurface,
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: context.colors.accentPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Novedades',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      StreamBuilder<QuerySnapshot>(
                        stream: AvisoService().avisosStream(),
                        builder: (context, avisoSnap) {
                          final docs = avisoSnap.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final avisos =
                              docs
                                  .map(
                                    (doc) => AvisoModel.fromMap(
                                      doc.id,
                                      doc.data() as Map<String, dynamic>,
                                    ),
                                  )
                                  .toList()
                                ..sort((a, b) {
                                  final aDate = a.publicado ?? DateTime(0);
                                  final bDate = b.publicado ?? DateTime(0);
                                  return bDate.compareTo(aDate);
                                });
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: avisos.length,
                                  itemBuilder: (context, index) =>
                                      _cardAviso(avisos[index]),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Explorá por institución',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/explore-instituciones',
                          );
                        },
                        child: Text(
                          'Ver todas',
                          style: TextStyle(
                            color: context.colors.accentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<List<InstitucionModel>>(
                    future: _cargarInstituciones(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No hay instituciones aún'),
                        );
                      }
                      final instituciones = List.of(snapshot.data!)
                        ..sort((a, b) {
                          final bool hasLogoA = a.logoURL.trim().isNotEmpty;
                          final bool hasLogoB = b.logoURL.trim().isNotEmpty;
                          if (hasLogoA && !hasLogoB) return -1; // A va primero
                          if (!hasLogoA && hasLogoB) return 1; // B va primero
                          return 0; // Se mantienen igual
                        });
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: instituciones.length,
                        itemBuilder: (context, index) {
                          final institucion = instituciones[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/institucion-carreras',
                                arguments: institucion.institucionUid,
                              );
                            },
                            child: Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: context.colors.bgSurface,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: context.colors.bgSurface,
                                      backgroundImage:
                                          institucion.logoURL.isNotEmpty
                                          ? NetworkImage(institucion.logoURL)
                                          : null,
                                      onBackgroundImageError:
                                          institucion.logoURL.isNotEmpty
                                          ? (_, _) {}
                                          : null,
                                      child: institucion.logoURL.isNotEmpty
                                          ? null
                                          : Icon(
                                              Icons.business,
                                              color: context.colors.iconNormal,
                                              size: 22,
                                            ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      institucion.nombre,
                                      style: TextStyle(
                                        color: context.colors.accentPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Expanded(
                                      child: Text(
                                        institucion.descripcion,
                                        style: TextStyle(
                                          color: context.colors.textSecondary,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 12,
                                          color: context.colors.iconNormal,
                                        ),
                                        const SizedBox(width: 2),
                                        Flexible(
                                          child: Text(
                                            institucion.ciudad.isNotEmpty
                                                ? institucion.ciudad
                                                : '',
                                            style: TextStyle(
                                              color:
                                                  context.colors.textSecondary,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Cerca de ti',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/map');
                        },
                        child: Text(
                          'Ver mapa completo',
                          style: TextStyle(
                            color: context.colors.accentPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FutureBuilder<List<InstitucionModel>>(
                    future: _cargarInstituciones(),
                    builder: (context, snapshot) {
                      final instituciones = snapshot.data ?? [];
                      final institucionesConCoords = instituciones
                          .where((i) => i.latitud != null && i.longitud != null)
                          .toList();
                      final primera = institucionesConCoords.isNotEmpty
                          ? institucionesConCoords.first
                          : null;

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 200,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: _userPosition != null
                                      ? LatLng(
                                          _userPosition!.latitude,
                                          _userPosition!.longitude,
                                        )
                                      : (primera != null
                                            ? LatLng(
                                                primera.latitud!,
                                                primera.longitud!,
                                              )
                                            : const LatLng(-34.6037, -58.3683)),
                                  initialZoom: 11,
                                  interactionOptions: const InteractionOptions(
                                    flags:
                                        InteractiveFlag.all &
                                        ~InteractiveFlag.rotate,
                                  ),
                                ),
                                children: [
                                  if (Theme.of(context).brightness ==
                                      Brightness.dark)
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        const Color(0xFF505966),
                                        BlendMode.multiply,
                                      ),
                                      child: TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'proyecto.app',
                                      ),
                                    )
                                  else
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'proyecto.app',
                                    ),
                                  MarkerLayer(
                                    markers: [
                                      ...institucionesConCoords.map(
                                        (inst) => Marker(
                                          point: LatLng(
                                            inst.latitud!,
                                            inst.longitud!,
                                          ),
                                          width: 32,
                                          height: 32,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/institucion',
                                                arguments: inst.institucionUid,
                                              );
                                            },
                                            child: Icon(
                                              Icons.location_pin,
                                              color:
                                                  context.colors.accentPrimary,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_userPosition != null)
                                        Marker(
                                          point: LatLng(
                                            _userPosition!.latitude,
                                            _userPosition!.longitude,
                                          ),
                                          width: 16,
                                          height: 16,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  context.colors.accentPrimary,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (primera != null)
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colors.bgSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            primera.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            primera.descripcion,
                                            style: TextStyle(
                                              color:
                                                  context.colors.textSecondary,
                                              fontSize: 11,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/institucion',
                                          arguments: primera.institucionUid,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            context.colors.accentPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                      child: const Text(
                                        'Ver detalles',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
