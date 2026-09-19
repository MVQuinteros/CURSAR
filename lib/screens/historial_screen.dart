import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/historial_model.dart';
import '../services/historial_service.dart';
import '../theme/app_theme.dart';

class HistorialScreen extends StatefulWidget {
  final String titulo;
  final String? tipo;

  const HistorialScreen({
    super.key,
    required this.titulo,
    this.tipo,
  });

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final HistorialService _historialService = HistorialService();

  String _abrirInstitucionDe(HistorialModel item) {
    if (item.tipo == 'institucion') {
      return item.id;
    }
    return item.institucionUid;
  }

  IconData _iconoDe(HistorialModel item) {
    return item.tipo == 'institucion'
        ? Icons.account_balance_outlined
        : Icons.auto_stories_outlined;
  }

  Color _colorDe(BuildContext context, HistorialModel item) {
    return item.tipo == 'institucion'
        ? context.colors.accentPrimary
        : const Color(0xFFEC4899);
  }

  String _fecha(HistorialModel item) {
    final f = item.createdAt;
    if (f == null) return '';
    return '${f.day}/${f.month}/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return Scaffold(
      backgroundColor: context.colors.bgMain,
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: uid.isEmpty
          ? Center(
              child: Text(
                'Iniciá sesión para ver tu historial',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            )
          : StreamBuilder<List<HistorialModel>>(
              stream: _historialService.historialStream(
                uid,
                tipo: widget.tipo,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Todavía no hay actividad.\nExplorá carreras e instituciones para ver tu historial acá.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: context.colors.borderSubtle),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final colorItem = _colorDe(context, item);
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorItem.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconoDe(item),
                          color: colorItem,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.nombre,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        [
                          if (item.tipo == 'carrera' &&
                              item.institucionNombre.isNotEmpty)
                            item.institucionNombre,
                          _fecha(item),
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: context.colors.iconNormal),
                      onTap: () {
                        final institucionUid = _abrirInstitucionDe(item);
                        if (institucionUid.isEmpty) return;
                        Navigator.pushNamed(
                          context,
                          '/institucion',
                          arguments: institucionUid,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}