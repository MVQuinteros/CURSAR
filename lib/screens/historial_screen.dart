import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/historial_model.dart';
import '../services/historial_service.dart';

const Color _kViolet = Color(0xFF8B5CF6);
const Color _kGreyText = Color(0xFF6B7280);

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

  Color _colorDe(HistorialModel item) {
    return item.tipo == 'institucion'
        ? _kViolet
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
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: _kViolet,
        foregroundColor: Colors.white,
        title: Text(widget.titulo),
      ),
      body: uid.isEmpty
          ? const Center(
              child: Text(
                'Iniciá sesión para ver tu historial',
                style: TextStyle(color: _kGreyText),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Todavía no hay actividad.\nExplorá carreras e instituciones para ver tu historial acá.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _kGreyText, height: 1.4),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _colorDe(item).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconoDe(item),
                          color: _colorDe(item),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kGreyText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing:
                          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
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