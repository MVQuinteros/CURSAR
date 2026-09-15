import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'models/oferta_model.dart';
import 'models/institucion_model.dart';
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
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
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
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high));
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

  Future<List<OfertaModel>> _cargarOfertas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ofertas')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) =>
            OfertaModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<InstitucionModel>> _cargarInstituciones() async {
    if (_institucionesCache != null) return _institucionesCache!;
    final snapshot =
        await FirebaseFirestore.instance.collection('instituciones').get();
    _institucionesCache = snapshot.docs
        .map((doc) => InstitucionModel.fromMap(doc.id, doc.data()))
        .toList();
    return _institucionesCache!;
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushNamed(context, '/test');
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Image.asset(
              'assets/imagenes/fondoLogin.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
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
                            Image.asset(
                              'assets/imagenes/logo.png',
                              height: 35,
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
                                      color: context.colors.accentPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Descubrí tu camino y empezá a construir tu futuro.',
                                    style: TextStyle(
                                      color: context.colors.textSecondary,
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
                        SizedBox(
                          height: 280,
                          child: FutureBuilder<List<OfertaModel>>(
                            future: _cargarOfertas(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('No hay novedades aún'));
                              }
                              final ofertas = snapshot.data!;
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: ofertas.length,
                                itemBuilder: (context, index) {
                                  final oferta = ofertas[index];
                                  final fecha = oferta.createdAt != null
                                      ? '${oferta.createdAt!.day}/${oferta.createdAt!.month}/${oferta.createdAt!.year}'
                                      : '';
                                  return Container(
                                    width: 220,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: context.colors.bgSurface,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 120,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: context.colors.bgSurface,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.image,
                                                  color: context.colors.iconNormal,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: context.colors.accentPrimary,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  oferta.tag,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                oferta.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                oferta.descripcion,
                                                style: TextStyle(
                                                  color: context.colors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 12,
                                                    color: context.colors.iconNormal,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    fecha,
                                                    style: TextStyle(
                                                      color: context.colors.textSecondary,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
                          onPressed: () {},
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
                          return const Center(child: Text('No hay instituciones aún'));
                        }
                        final instituciones = snapshot.data!;
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
                                  '/institucion',
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
                                      backgroundImage: institucion
                                              .logoURL.isNotEmpty
                                          ? NetworkImage(institucion.logoURL)
                                          : null,
                                      onBackgroundImageError: institucion
                                              .logoURL.isNotEmpty
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
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                              color: context.colors.textSecondary,
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
                                        ? LatLng(_userPosition!.latitude,
                                            _userPosition!.longitude)
                                        : (primera != null
                                            ? LatLng(primera.latitud!,
                                                primera.longitud!)
                                            : const LatLng(-34.6037, -58.3683)),
                                    initialZoom: 11,
                                    interactionOptions:
                                        const InteractionOptions(
                                      flags: InteractiveFlag.all &
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
                                            point: LatLng(inst.latitud!,
                                                inst.longitud!),
                                            width: 32,
                                            height: 32,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/institucion',
                                                  arguments:
                                                      inst.institucionUid,
                                                );
                                              },
                                              child: Icon(
                                                Icons.location_pin,
                                                color: context.colors.accentPrimary,
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (_userPosition != null)
                                          Marker(
                                            point: LatLng(
                                                _userPosition!.latitude,
                                                _userPosition!.longitude),
                                            width: 16,
                                            height: 16,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: context.colors.accentPrimary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
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
                                        color: Colors.black
                                            .withValues(alpha: 0.1),
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
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              primera.descripcion,
                                              style: TextStyle(
                                                color: context.colors.textSecondary,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
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
                                            arguments:
                                                primera.institucionUid,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              context.colors.accentPrimary,
                                          padding:
                                              const EdgeInsets.symmetric(
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
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