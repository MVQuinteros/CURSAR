import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/institucion_model.dart';
import '../services/ubicacion_service.dart';
import '../theme/app_theme.dart';

class ExploreInstitucionesScreen extends StatefulWidget {
  const ExploreInstitucionesScreen({super.key});

  @override
  State<ExploreInstitucionesScreen> createState() =>
      _ExploreInstitucionesScreenState();
}

class _InstDist {
  const _InstDist(this.inst, this.dist);

  final InstitucionModel inst;
  final double? dist;
}

class _ExploreInstitucionesScreenState extends State<ExploreInstitucionesScreen> {
  late Future<List<_InstDist>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargarLista();
  }

  Future<List<_InstDist>> _cargarLista() async {
    final snap = await FirebaseFirestore.instance
        .collection('instituciones')
        .get();
    final instituciones = snap.docs
        .map((doc) => InstitucionModel.fromMap(doc.id, doc.data()))
        .toList();

    final pos = await UbicacionService.obtenerPosicion();

    final items = instituciones.map((inst) {
      double? dist;
      if (pos != null && inst.latitud != null && inst.longitud != null) {
        dist = UbicacionService.distanciaKm(
          pos.latitude,
          pos.longitude,
          inst.latitud!,
          inst.longitud!,
        );
      }
      return _InstDist(inst, dist);
    }).toList();

    items.sort((a, b) {
      if (a.dist == null && b.dist == null) {
        return a.inst.nombre.compareTo(b.inst.nombre);
      }
      if (a.dist == null) return 1;
      if (b.dist == null) return -1;
      return a.dist!.compareTo(b.dist!);
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgMain,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 20, 0),
              child: Row(
                children: [
                  BackButton(
                    color: context.colors.textPrimary,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Explorá por institución',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Instituciones ordenadas por cercanía',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<_InstDist>>(
                future: _futuro,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay instituciones disponibles',
                        style: TextStyle(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    );
                  }
                  final items = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _tarjetaInstitucion(items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaInstitucion(_InstDist item) {
    final inst = item.inst;
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/institucion-carreras',
        arguments: inst.institucionUid,
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _logoInstitucion(inst),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inst.nombre,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    inst.descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.dist != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: context.colors.accentPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          UbicacionService.formatearKm(item.dist!),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: context.colors.iconNormal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoInstitucion(InstitucionModel inst) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: context.colors.bgSurface,
      child: ClipOval(
        child: inst.logoURL.isNotEmpty
            ? Image.network(
                inst.logoURL,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.school,
                  size: 26,
                  color: context.colors.accentPrimary,
                ),
              )
            : Icon(
                Icons.school,
                size: 26,
                color: context.colors.accentPrimary,
              ),
      ),
    );
  }
}