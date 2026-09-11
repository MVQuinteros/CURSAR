import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/institucion_model.dart';
import '../models/oferta_model.dart';
import '../services/historial_service.dart';

class InstitucionDetailScreen extends StatefulWidget {
  final String institucionUid;

  const InstitucionDetailScreen({super.key, required this.institucionUid});

  @override
  State<InstitucionDetailScreen> createState() =>
      _InstitucionDetailScreenState();
}

class _InstitucionDetailScreenState extends State<InstitucionDetailScreen> {
  InstitucionModel? _institucion;
  List<OfertaModel> _ofertas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final instDoc = await FirebaseFirestore.instance
        .collection('instituciones')
        .doc(widget.institucionUid)
        .get();

    if (instDoc.exists) {
      _institucion = InstitucionModel.fromMap(instDoc.id, instDoc.data()!);
    }

    final ofertasSnap = await FirebaseFirestore.instance
        .collection('ofertas')
        .where('institucionUid', isEqualTo: widget.institucionUid)
        .get();

    setState(() {
      _ofertas = ofertasSnap.docs
          .map((doc) => OfertaModel.fromMap(doc.id, doc.data()))
          .toList()
        ..sort((a, b) {
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
      _loading = false;

      _registrarHistorial(_institucion, _ofertas);
    });
  }

  Future<void> _registrarHistorial(
    InstitucionModel? inst,
    List<OfertaModel> ofertas,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || inst == null) return;
    try {
      final service = HistorialService();
      await service.registrar(
        uid: user.uid,
        tipo: 'institucion',
        id: inst.institucionUid,
        nombre: inst.nombre,
      );
      for (final oferta in ofertas) {
        await service.registrar(
          uid: user.uid,
          tipo: 'carrera',
          id: oferta.ofertaId,
          nombre: oferta.nombre,
          institucionUid: inst.institucionUid,
          institucionNombre: inst.nombre,
        );
      }
    } catch (_) {}
  }

  Future<void> _abrirEnGoogleMaps() async {
    if (_institucion == null) return;
    final lat = _institucion!.latitud;
    final lng = _institucion!.longitud;
    if (lat == null || lng == null) {
      final query = Uri.encodeComponent(
          '${_institucion!.direccion}, ${_institucion!.ciudad}');
      final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$query');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }
    final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirSitioWeb() async {
    if (_institucion?.sitioWeb == null || _institucion!.sitioWeb.isEmpty) return;
    final url = Uri.parse(_institucion!.sitioWeb);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'INSCRIPCIONES ABIERTAS':
        return Colors.green;
      case 'NUEVO':
        return Colors.blue;
      case 'BECAS':
        return Colors.orange;
      case 'FECHAS IMPORTANTES':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          title: const Text('Cargando...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_institucion == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A237E),
          foregroundColor: Colors.white,
          title: const Text('Error'),
        ),
        body: const Center(child: Text('Institución no encontrada')),
      );
    }

    final inst = _institucion!;
    final tieneCoordenadas = inst.latitud != null && inst.longitud != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: Text(inst.nombre),
        actions: [
          if (inst.sitioWeb.isNotEmpty)
            IconButton(
              onPressed: _abrirSitioWeb,
              icon: const Icon(Icons.language),
              tooltip: 'Sitio web',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tieneCoordenadas)
              SizedBox(
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(inst.latitud!, inst.longitud!),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'proyecto.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(inst.latitud!, inst.longitud!),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Color(0xFF1A237E),
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (inst.logoURL.isNotEmpty) ...[
                    Center(
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            inst.logoURL,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.school,
                              size: 45,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    inst.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inst.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _infoRow(Icons.location_on, inst.direccion),
                  _infoRow(Icons.location_city, '${inst.ciudad}, ${inst.provincia}'),
                  _infoRow(Icons.phone, inst.telefono),
                  _infoRow(Icons.email, inst.email),
                  if (inst.sitioWeb.isNotEmpty)
                    _infoRow(Icons.language, inst.sitioWeb),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _abrirEnGoogleMaps,
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text(
                        'Cómo llegar',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ofertas académicas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_ofertas.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No hay ofertas disponibles',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ..._ofertas.map((oferta) => _ofertaCard(oferta)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1A237E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ofertaCard(OfertaModel oferta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    oferta.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _tagColor(oferta.tag).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    oferta.tag,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _tagColor(oferta.tag),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              oferta.descripcion,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _ofertaChip(Icons.school, oferta.nivel),
                _ofertaChip(Icons.access_time,
                    '${oferta.duracionAnios} ${oferta.duracionAnios == 1 ? 'año' : 'años'}'),
                _ofertaChip(Icons.computer, oferta.modalidad),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    oferta.salidaLaboral,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ofertaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
