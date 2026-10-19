import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reporte_model.dart';
import '../services/soporte_service.dart';
import '../theme/app_theme.dart';

/// Historial de reportes y solicitudes que el usuario envió desde
/// "Ayuda y soporte", con su estado y la respuesta del administrador.
class SolicitudesHistorialScreen extends StatelessWidget {
  const SolicitudesHistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: context.colors.bgMain,
      appBar: AppBar(
        title: const Text('Mis solicitudes y reportes'),
      ),
      body: user == null
          ? const _EstadoVacio(
              icono: Icons.person_off_outlined,
              texto: 'Ingresá a tu cuenta para ver tus solicitudes',
            )
          : StreamBuilder<List<ReporteModel>>(
              stream: SoporteService().getReportesUsuario(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _EstadoError(error: snapshot.error.toString());
                }

                final reportes = snapshot.data ?? const <ReporteModel>[];
                if (reportes.isEmpty) {
                  return const _EstadoVacio(
                    icono: Icons.inbox_outlined,
                    texto: 'Aún no tienes solicitudes o reportes enviados',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reportes.length,
                  itemBuilder: (context, index) =>
                      _SolicitudCard(reporte: reportes[index]),
                );
              },
            ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final ReporteModel reporte;

  const _SolicitudCard({required this.reporte});

  @override
  Widget build(BuildContext context) {
    final respondido = reporte.estado == 'respondido';
    final respuesta = reporte.respuestaAdmin?.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + badge de estado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reporte.tipo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _BadgeEstado(estado: reporte.estado),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reporte.mensaje,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.textSecondary,
              height: 1.4,
            ),
          ),
          // Respuesta del administrador, solo si existe
          if (respondido && respuesta != null && respuesta.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.bgMain,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 16,
                        color: context.colors.accentPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Respuesta del equipo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.colors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    respuesta,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _tiempoTranscurrido(reporte.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// "Hace 2 días", "Hace 3 horas", "Recién"...
  String _tiempoTranscurrido(DateTime? fecha) {
    if (fecha == null) return 'Fecha desconocida';
    final diff = DateTime.now().difference(fecha);

    if (diff.inMinutes < 1) return 'Recién';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    }
    if (diff.inDays < 30) {
      return 'Hace ${diff.inDays} ${diff.inDays == 1 ? 'día' : 'días'}';
    }
    if (diff.inDays < 365) {
      final meses = (diff.inDays / 30).floor();
      return 'Hace $meses ${meses == 1 ? 'mes' : 'meses'}';
    }
    final anios = (diff.inDays / 365).floor();
    return 'Hace $anios ${anios == 1 ? 'año' : 'años'}';
  }
}

/// Devuelve (colorFondo, colorTexto) segun el estado, normalizando
/// el texto para tolerar mayusculas, espacios, guiones bajos y
/// variantes 'en_revision' y 'en revision' con o sin tilde.
/// Colores solidos (sin opacidad) para coincidir con los mockups.
({Color fondo, Color texto}) _getColorForEstado(String estado) {
  final normalizado = estado.trim().toLowerCase().replaceAll('_', ' ');

  switch (normalizado) {
    case 'respondido':
      return (
        fondo: const Color(0xFF3BA55D), // verde solido del mockup
        texto: Colors.white,
      );
    case 'en revisión':
    case 'en revision':
      return (
        fondo: const Color(0xFFF6B96A), // naranja suave/amarillento solido
        texto: Colors.black87,
      );
    default: // 'pendiente' u otro valor desconocido
      return (
        fondo: const Color(0xFFE5E7EB), // gris claro solido
        texto: Colors.grey.shade800,
      );
  }
}

class _BadgeEstado extends StatelessWidget {
  final String estado;

  const _BadgeEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    // Misma normalizacion que _getColorForEstado para que la etiqueta
    // visible y los colores siempre coincidan.
    final normalizado = estado.trim().toLowerCase().replaceAll('_', ' ');
    final etiqueta = switch (normalizado) {
      'respondido' => 'Respondido',
      'en revisión' => 'En revisión',
      _ => 'Pendiente',
    };
    final colores = _getColorForEstado(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colores.fondo,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        etiqueta,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colores.texto,
        ),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _EstadoVacio({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 72,
              color: context.colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  final String error;

  const _EstadoError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 72,
              color: Colors.red.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudieron cargar tus solicitudes.\nIntentá de nuevo en unos minutos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
