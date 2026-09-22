import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/institucion_model.dart';
import '../models/oferta_model.dart';
import '../services/favorito_service.dart';
import '../services/ubicacion_service.dart';
import '../theme/app_theme.dart';

class InstitucionCarrerasScreen extends StatefulWidget {
  final String institucionUid;

  const InstitucionCarrerasScreen({super.key, required this.institucionUid});

  @override
  State<InstitucionCarrerasScreen> createState() =>
      _InstitucionCarrerasScreenState();
}

class _InstitucionCarrerasScreenState extends State<InstitucionCarrerasScreen> {
  InstitucionModel? _inst;
  List<OfertaModel> _ofertas = [];
  bool _loading = true;
  double? _dist;
  StreamSubscription<QuerySnapshot>? _favSub;
  Map<String, String> _favDocIds = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _cargarFavoritos();
  }

  @override
  void dispose() {
    _favSub?.cancel();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final instDoc = await FirebaseFirestore.instance
        .collection('instituciones')
        .doc(widget.institucionUid)
        .get();

    InstitucionModel? inst;
    if (instDoc.exists) {
      inst = InstitucionModel.fromMap(instDoc.id, instDoc.data()!);
    }

    final ofertasSnap = await FirebaseFirestore.instance
        .collection('ofertas')
        .where('institucionUid', isEqualTo: widget.institucionUid)
        .get();

    final pos = await UbicacionService.obtenerPosicion();

    if (mounted) {
      double? dist;
      if (pos != null &&
          inst != null &&
          inst.latitud != null &&
          inst.longitud != null) {
        dist = UbicacionService.distanciaKm(
          pos.latitude,
          pos.longitude,
          inst.latitud!,
          inst.longitud!,
        );
      }
      setState(() {
        _inst = inst;
        _dist = dist;
        _ofertas = ofertasSnap.docs
            .map((doc) => OfertaModel.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) {
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
        _loading = false;
      });
    }
  }

  void _cargarFavoritos() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _favSub = FavoritoService().favoritosStream(user.uid).listen((snap) {
      final docs = <String, String>{};
      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ofertaId = data['ofertaId']?.toString();
        if (ofertaId != null) docs[ofertaId] = doc.id;
      }
      if (mounted) setState(() => _favDocIds = docs);
    });
  }

  Future<void> _toggleFavorito(OfertaModel oferta) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final service = FavoritoService();
    try {
      if (_favDocIds.containsKey(oferta.ofertaId)) {
        await service.eliminarFavorito(
          user.uid,
          _favDocIds[oferta.ofertaId]!,
        );
      } else {
        await service.agregarFavorito(
          user.uid,
          oferta.ofertaId,
          widget.institucionUid,
        );
      }
    } catch (_) {}
  }

  Future<void> _mostrarCarrera(OfertaModel oferta) {
    final inst = _inst;
    if (inst == null) return Future.value();
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Theme.of(dialogContext).extension<AppColors>()?.bgSurface,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                oferta.nombre,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sitio oficial de la carrera en la web\nde ${inst.nombre}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _abrirSitioOficial(inst, dialogContext),
                  icon: const Icon(
                    Icons.launch,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Ir al sitio oficial',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.accentPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        Theme.of(dialogContext).extension<AppColors>()?.bgSurface,
                    foregroundColor: context.colors.accentPrimary,
                    side: BorderSide(color: context.colors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirSitioOficial(
    InstitucionModel inst,
    BuildContext dialogContext,
  ) async {
    Navigator.pop(dialogContext);
    final url = inst.sitioWeb;
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No hay sitio web disponible para ${inst.nombre}.')),
        );
      }
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_inst == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Institución no encontrada')),
      );
    }

    final inst = _inst!;

    return Scaffold(
      backgroundColor: context.colors.bgMain,
      appBar: AppBar(title: Text(inst.nombre)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _logoInstitucion(inst)),
            const SizedBox(height: 14),
            Text(
              inst.nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              inst.descripcion,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: context.colors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (_dist != null)
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: context.colors.accentPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'A ${UbicacionService.formatearKm(_dist!)} de tu ubicación',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),
            Text(
              'Carreras que ofrece',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (_ofertas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No hay carreras disponibles',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                ),
              )
            else
              ..._buildCarreras(),
          ],
        ),
      ),
    );
  }

  Widget _logoInstitucion(InstitucionModel inst) {
    return CircleAvatar(
      radius: 44,
      backgroundColor: context.colors.bgSurface,
      child: ClipOval(
        child: inst.logoURL.isNotEmpty
            ? Image.network(
                inst.logoURL,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.school,
                  size: 44,
                  color: context.colors.accentPrimary,
                ),
              )
            : Icon(
                Icons.school,
                size: 44,
                color: context.colors.accentPrimary,
              ),
      ),
    );
  }

  List<Widget> _buildCarreras() {
    final filas = <Widget>[];
    for (var i = 0; i < _ofertas.length; i++) {
      filas.add(_carreraFila(_ofertas[i]));
      if (i < _ofertas.length - 1) {
        filas.add(Divider(height: 1, color: context.colors.borderSubtle));
      }
    }
    return filas;
  }

  Widget _carreraFila(OfertaModel oferta) {
    final esFavorita = _favDocIds.containsKey(oferta.ofertaId);
    return InkWell(
      onTap: () => _mostrarCarrera(oferta),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                oferta.nombre,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            InkWell(
              onTap: () => _toggleFavorito(oferta),
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  esFavorita ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color: esFavorita
                      ? context.colors.accentPrimary
                      : context.colors.iconNormal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}