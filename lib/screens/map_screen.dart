import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/institucion_model.dart';
import '../services/ubicacion_service.dart';
import '../theme/app_theme.dart';

class _InstDist {
  final InstitucionModel inst;
  final double? km;

  const _InstDist(this.inst, this.km);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<InstitucionModel> _instituciones = [];
  List<_InstDist> _conDistancia = [];
  double? _userLat;
  double? _userLng;
  int _radioKm = 20;
  bool _modoArea = true;
  bool _mostrarCercaDeMi = false;
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

    final pos = await UbicacionService.obtenerPosicion();
    final radio = await UbicacionService.obtenerRadioBusqueda();

    if (mounted) {
      setState(() {
        _instituciones = instituciones;
        _conDistancia = _calcularDistancias(instituciones, pos);
        _userLat = pos?.latitude;
        _userLng = pos?.longitude;
        _radioKm = radio;
        _loading = false;
      });
    }
  }

  List<_InstDist> _calcularDistancias(
      List<InstitucionModel> instituciones, Position? pos) {
    if (pos == null) {
      return instituciones
          .where((i) => i.latitud != null && i.longitud != null)
          .map((i) => _InstDist(i, null))
          .toList();
    }
    final lista = instituciones
        .where((i) => i.latitud != null && i.longitud != null)
        .map((i) => _InstDist(
              i,
              UbicacionService.distanciaKm(
                pos.latitude,
                pos.longitude,
                i.latitud!,
                i.longitud!,
              ),
            ))
        .toList()
      ..sort((a, b) => (a.km ?? 0).compareTo(b.km ?? 0));
    return lista;
  }

  List<_InstDist> get _visibles {
    if (_modoArea && _userLat != null && _userLng != null) {
      return _conDistancia.where((x) => (x.km ?? double.infinity) <= _radioKm).toList();
    }
    return _conDistancia;
  }

  void _centrarEnMiUbicacion() {
    if (_userLat != null && _userLng != null) {
      _mapController.move(LatLng(_userLat!, _userLng!), 13);
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

  Future<void> _abrirComoLlegar(
    InstitucionModel inst,
    ModoViaje modo,
    BuildContext sheetContext,
  ) async {
    final destino = (inst.latitud != null && inst.longitud != null)
        ? '${inst.latitud},${inst.longitud}'
        : Uri.encodeComponent('${inst.direccion}, ${inst.ciudad}');
    final origen =
        (_userLat != null && _userLng != null) ? '$_userLat,$_userLng' : null;
    final travelmode = switch (modo) {
      ModoViaje.auto => 'driving',
      ModoViaje.caminando => 'walking',
      ModoViaje.transporte => 'transit',
    };
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '${origen != null ? '&origin=$origen' : ''}'
      '&destination=$destino'
      '&travelmode=$travelmode',
    );
    if (await canLaunchUrl(url)) {
      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showInstitucionInfo(InstitucionModel inst) {
    double? dist;
    if (_userLat != null && _userLng != null && inst.latitud != null && inst.longitud != null) {
      dist = UbicacionService.distanciaKm(
        _userLat!, _userLng!, inst.latitud!, inst.longitud!);
    }
    final tiempos = dist != null ? UbicacionService.tiempos(dist) : null;

    var modo = ModoViaje.auto;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inst.nombre,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  inst.descripcion,
                  style: TextStyle(
                      fontSize: 13, color: context.colors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: context.colors.accentPrimary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${inst.direccion}, ${inst.ciudad}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (dist != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.near_me,
                          size: 16, color: context.colors.accentPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'A ${UbicacionService.formatearKm(dist)} de tu ubicación',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
                if (tiempos != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildChipViaje(
                        context: context,
                        icon: Icons.directions_car,
                        label: '${tiempos.autoMin} min',
                        seleccionado: modo == ModoViaje.auto,
                        onTap: () =>
                            setSheetState(() => modo = ModoViaje.auto),
                      ),
                      const SizedBox(width: 8),
                      _buildChipViaje(
                        context: context,
                        icon: Icons.directions_walk,
                        label: '${tiempos.caminandoMin} min',
                        seleccionado: modo == ModoViaje.caminando,
                        onTap: () => setSheetState(
                            () => modo = ModoViaje.caminando),
                      ),
                      const SizedBox(width: 8),
                      _buildChipViaje(
                        context: context,
                        icon: Icons.directions_bus,
                        label: '${tiempos.transporteMin} min',
                        seleccionado: modo == ModoViaje.transporte,
                        onTap: () => setSheetState(
                            () => modo = ModoViaje.transporte),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _abrirComoLlegar(inst, modo, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.accentPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cómo llegar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/institucion',
                        arguments: inst.institucionUid,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.accentPrimary,
                      side: BorderSide(color: context.colors.accentPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Ver detalles'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChipViaje({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    final accent = context.colors.accentPrimary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: seleccionado
                ? accent.withValues(alpha: 0.15)
                : context.colors.borderSubtle.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: seleccionado ? accent : context.colors.borderSubtle,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: seleccionado ? accent : context.colors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: seleccionado
                      ? accent
                      : context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanelCercaDeMi() {
    final lista = _visibles.take(8).toList();
    if (lista.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 88,
      bottom: 24,
      child: Material(
        color: context.colors.bgSurface,
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () =>
                  setState(() => _mostrarCercaDeMi = !_mostrarCercaDeMi),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    Icon(Icons.near_me,
                        size: 18, color: context.colors.accentPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cerca de mí',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _mostrarCercaDeMi
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (_mostrarCercaDeMi)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    final km = item.km;
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.school,
                        size: 20,
                        color: context.colors.accentPrimary,
                      ),
                      title: Text(
                        item.inst.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        km != null ? UbicacionService.formatearKm(km) : '',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      onTap: () => _showInstitucionInfo(item.inst),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mapa de universidades'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final tieneUbicacion = _userLat != null && _userLng != null;
    final visibles = _visibles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de universidades'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: tieneUbicacion
                  ? LatLng(_userLat!, _userLng!)
                  : _buenosAiresCenter,
              initialZoom: 11,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              if (oscuro)
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
              if (tieneUbicacion)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(_userLat!, _userLng!),
                      radius: _radioKm * 1000,
                      color: context.colors.accentPrimary.withValues(alpha: 0.12),
                      borderColor:
                          context.colors.accentPrimary.withValues(alpha: 0.5),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...visibles.map(
                    (item) {
                      final inst = item.inst;
                      return Marker(
                        point: LatLng(inst.latitud!, inst.longitud!),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _showInstitucionInfo(inst),
                          child: inst.logoURL.isNotEmpty
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundColor: context.colors.bgSurface,
                                  child: ClipOval(
                                    child: Image.network(
                                      inst.logoURL,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.location_pin,
                                        color: context.colors.accentPrimary,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.location_pin,
                                  color: context.colors.accentPrimary,
                                  size: 40,
                                ),
                        ),
                      );
                    },
                  ),
                  if (tieneUbicacion)
                    Marker(
                      point: LatLng(_userLat!, _userLng!),
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.accentPrimary,
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
          if (tieneUbicacion)
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Material(
                color: context.colors.bgSurface,
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.travel_explore,
                          size: 18, color: context.colors.accentPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Solo dentro de mi área',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Switch(
                        value: _modoArea,
                        activeThumbColor: context.colors.accentPrimary,
                        onChanged: (v) => setState(() => _modoArea = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'userLocation',
                  backgroundColor: context.colors.bgSurface,
                  onPressed: _centrarEnMiUbicacion,
                  child: Icon(Icons.my_location,
                      color: context.colors.accentPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'nearme',
                  backgroundColor: context.colors.bgSurface,
                  onPressed: () => setState(
                      () => _mostrarCercaDeMi = !_mostrarCercaDeMi),
                  child: Icon(Icons.format_list_bulleted,
                      color: context.colors.accentPrimary),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'allInstitutions',
                  backgroundColor: context.colors.bgSurface,
                  onPressed: _centrarEnInstituciones,
                  child: Icon(Icons.unfold_more,
                      color: context.colors.accentPrimary),
                ),
              ],
            ),
          ),
          _buildPanelCercaDeMi(),
        ],
      ),
    );
  }
}