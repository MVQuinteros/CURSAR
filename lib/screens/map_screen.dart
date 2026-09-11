import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/institucion_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<InstitucionModel> _instituciones = [];
  Position? _userPosition;
  bool _loading = true;

  static const LatLng _buenosAiresCenter = LatLng(-34.6037, -58.3683);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('instituciones').get();

    final instituciones = snapshot.docs
        .map((doc) => InstitucionModel.fromMap(doc.id, doc.data()))
        .toList();

    Position? pos;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever) {
          if (mounted) _mostrarDialogoPermisoUbicacion();
        } else if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          pos = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high));
        }
      }
    } catch (_) {}

    setState(() {
      _instituciones = instituciones;
      _userPosition = pos;
      _loading = false;
    });
  }

  void _centrarEnMiUbicacion() {
    if (_userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        13,
      );
    }
  }

  void _centrarEnInstituciones() {
    if (_instituciones.isEmpty) return;
    final coords = _instituciones
        .where((i) => i.latitud != null && i.longitud != null)
        .map((i) => LatLng(i.latitud!, i.longitud!))
        .toList();
    if (coords.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(coords);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
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
              backgroundColor: const Color(0xFF1A237E),
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

  void _showInstitucionInfo(InstitucionModel inst) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                inst.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                inst.descripcion,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 16, color: Color(0xFF1A237E)),
                  const SizedBox(width: 6),
                  Text(
                    '${inst.direccion}, ${inst.ciudad}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/institucion',
                      arguments: inst.institucionUid,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Ver detalles',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          title: const Text('Mapa de universidades'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final institucionesConCoords = _instituciones
        .where((i) => i.latitud != null && i.longitud != null)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Mapa de universidades'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPosition != null
                  ? LatLng(
                      _userPosition!.latitude, _userPosition!.longitude)
                  : _buenosAiresCenter,
              initialZoom: 11,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'proyecto.app',
              ),
              MarkerLayer(
                markers: [
                  ...institucionesConCoords.map(
                    (inst) => Marker(
                      point: LatLng(inst.latitud!, inst.longitud!),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showInstitucionInfo(inst),
                        child: inst.logoURL.isNotEmpty
                            ? CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.network(
                                    inst.logoURL,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.location_pin,
                                      color: Color(0xFF1A237E),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.location_pin,
                                color: Color(0xFF1A237E),
                                size: 40,
                              ),
                      ),
                    ),
                  ),
                  if (_userPosition != null)
                    Marker(
                      point: LatLng(
                          _userPosition!.latitude, _userPosition!.longitude),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'userLocation',
                  backgroundColor: Colors.white,
                  onPressed: _centrarEnMiUbicacion,
                  child: const Icon(Icons.my_location, color: Color(0xFF1A237E)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'allInstitutions',
                  backgroundColor: Colors.white,
                  onPressed: _centrarEnInstituciones,
                  child: const Icon(Icons.unfold_more, color: Color(0xFF1A237E)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
