import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reporte_model.dart';
import '../services/soporte_service.dart';
import '../theme/app_theme.dart';

/// "Mis reportes": lo que el usuario mandó desde Ayuda y soporte, con la
/// respuesta del equipo de soporte.
///
/// El panel guarda la respuesta en `respuesta` y marca `estado` como
/// `resuelto`; el reporte se atribuye al usuario por el campo `uid`.
class MisReportesScreen extends StatefulWidget {
  const MisReportesScreen({super.key});

  @override
  State<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends State<MisReportesScreen> {
  late final Stream<List<ReporteModel>> _reportes;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _reportes = (uid == null || uid.isEmpty)
        ? Stream<List<ReporteModel>>.value(const <ReporteModel>[])
        : SoporteService().misReportes(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgMain,
      appBar: AppBar(title: const Text('Mis reportes')),
      body: StreamBuilder<List<ReporteModel>>(
        stream: _reportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _Aviso(
              icono: Icons.cloud_off_outlined,
              texto: 'No pudimos cargar tus reportes.\n'
                  'Volvé a intentar en un rato.',
            );
          }
          final reportes = snapshot.data ?? const <ReporteModel>[];
          if (reportes.isEmpty) {
            return const _Aviso(
              icono: Icons.forum_outlined,
              texto: 'Todavía no enviaste reportes.\n'
                  'Podés hacerlo desde Ayuda y soporte.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: reportes.length,
            itemBuilder: (context, i) => _TarjetaReporte(reporte: reportes[i]),
          );
        },
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({required this.reporte});

  final ReporteModel reporte;

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final respuesta = reporte.respuesta;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colores.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colores.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
                  reporte.tipo.isEmpty ? 'Reporte' : reporte.tipo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colores.textPrimary,
                  ),
                ),
              ),
              _Estado(resuelto: reporte.resuelto),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reporte.mensaje,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colores.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fecha(reporte.createdAt),
            style: TextStyle(fontSize: 11, color: colores.textSecondary),
          ),
          if (respuesta != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colores.bgMain,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colores.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 16,
                        color: colores.accentPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Respuesta de soporte',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colores.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    respuesta,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: colores.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Estado extends StatelessWidget {
  const _Estado({required this.resuelto});

  final bool resuelto;

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final color = resuelto ? const Color(0xFF2E9E5B) : colores.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        resuelto ? 'Resuelto' : 'Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48, color: colores.textSecondary),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: colores.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fecha(DateTime? fecha) {
  if (fecha == null) return '';
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  final hora = fecha.hour.toString().padLeft(2, '0');
  final minuto = fecha.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year} · $hora:$minuto';
}
