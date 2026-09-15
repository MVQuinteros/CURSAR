import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/aviso_model.dart';
import '../models/notificacion_model.dart';
import '../services/aviso_service.dart';
import '../services/notificacion_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  static const Color _darkNavy = Color(0xFF1A237E);

  final NotificacionService _notificacionService = NotificacionService();
  final AvisoService _avisoService = AvisoService();

  String? _userUid;
  Set<String> _avisosLeidos = {};
  List<AvisoModel> _avisos = [];

  @override
  void initState() {
    super.initState();
    _userUid = FirebaseAuth.instance.currentUser?.uid;
    _cargarAvisos();
  }

  Future<void> _cargarAvisos() async {
    final avisos = await _avisoService.obtenerAvisos();
    avisos.sort((a, b) {
      final aDate = a.publicado ?? DateTime(0);
      final bDate = b.publicado ?? DateTime(0);
      return bDate.compareTo(aDate);
    });
    final uid = _userUid;
    Set<String> leidos = {};
    if (uid != null) {
      leidos = (await _avisoService.obtenerAvisosLeidos(uid)).toSet();
    }
    if (mounted) {
      setState(() {
        _avisos = avisos;
        _avisosLeidos = leidos;
      });
    }
  }

  Future<void> _marcarTodoComoLeido() async {
    final uid = _userUid;
    if (uid == null) return;
    await _notificacionService.marcarTodasComoLeido(uid);
    await _avisoService.marcarTodosAvisosLeidos(
        uid, _avisos.map((a) => a.avisoId).toList());
    if (mounted) {
      setState(() {
        _avisosLeidos = _avisos.map((a) => a.avisoId).toSet();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todas las notificaciones fueron leídas')),
      );
    }
  }

  Future<void> _abrirLink(String link) async {
    await Navigator.pushNamed(context, link);
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final hoy = DateTime.now();
    final diff = hoy.difference(fecha).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  IconData _iconoPorTipo(String tipo) {
    switch (tipo) {
      case 'inscripcion':
        return Icons.event_available;
      case 'noticia':
        return Icons.newspaper;
      case 'consejo':
        return Icons.tips_and_updates;
      case 'bienvenida':
        return Icons.celebration;
      case 'test':
        return Icons.school;
      default:
        return Icons.notifications;
    }
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'inscripcion':
        return const Color(0xFF2E7D32);
      case 'noticia':
        return const Color(0xFF1565C0);
      case 'consejo':
        return const Color(0xFFF9A825);
      case 'bienvenida':
        return const Color(0xFF6A1B9A);
      default:
        return _darkNavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: AppBar(
        backgroundColor: _darkNavy,
        foregroundColor: Colors.white,
        title: const Text('Notificaciones'),
        actions: [
          TextButton.icon(
            onPressed: _marcarTodoComoLeido,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Marcar todas'),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notificacionService.notificacionesStream(
            _userUid ?? 'usuario_vacio'),
        builder: (context, snapshot) {
          List<NotificacionModel> notificaciones = [];
          if (snapshot.hasData) {
            notificaciones = snapshot.data!.docs
                .map((doc) => NotificacionModel.fromMap(
                    doc.id, doc.data() as Map<String, dynamic>))
                .toList();
            notificaciones.sort((a, b) {
              final aDate = a.createdAt ?? DateTime(0);
              final bDate = b.createdAt ?? DateTime(0);
              return bDate.compareTo(aDate);
            });
          }
          return _contenido(notificaciones, snapshot.connectionState);
        },
      ),
    );
  }

  Widget _contenido(
    List<NotificacionModel> notificaciones,
    ConnectionState connection,
  ) {
    final sinDatos =
        _avisos.isEmpty && notificaciones.isEmpty && connection != ConnectionState.waiting;

    if (sinDatos) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 72, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No tenés notificaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Cuando haya novedades sobre inscripciones,\nte las mostramos acá.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (_avisos.isNotEmpty) ...[
          const _SeccionHeader('Noticias de inscripciones'),
          ..._avisos.map(_cardAviso),
        ],
        if (notificaciones.isNotEmpty) ...[
          const _SeccionHeader('Tus notificaciones'),
          ...notificaciones.map(_cardNotificacion),
        ],
      ],
    );
  }

  Widget _cardAviso(AvisoModel aviso) {
    final leido = _avisosLeidos.contains(aviso.avisoId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: leido ? Colors.white : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (!leido) {
              final uid = _userUid;
              if (uid != null) {
                await _avisoService.marcarAvisoLeido(uid, aviso.avisoId);
              }
              if (mounted) {
                setState(() => _avisosLeidos.add(aviso.avisoId));
              }
            }
            if (aviso.link != null && aviso.link!.isNotEmpty) {
              await _abrirLink(aviso.link!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _colorPorTipo(aviso.tipo).withValues(alpha: 0.15),
                  child: Icon(
                    _iconoPorTipo(aviso.tipo),
                    color: _colorPorTipo(aviso.tipo),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aviso.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: leido ? Colors.grey[700] : _darkNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aviso.mensaje,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatearFecha(aviso.publicado),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!leido) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardNotificacion(NotificacionModel notificacion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: notificacion.leido ? Colors.white : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (!notificacion.leido) {
              await _notificacionService
                  .marcarComoLeido(notificacion.notificacionId);
            }
            if (notificacion.link != null &&
                notificacion.link!.isNotEmpty) {
              await _abrirLink(notificacion.link!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      _colorPorTipo(notificacion.tipo).withValues(alpha: 0.15),
                  child: Icon(
                    _iconoPorTipo(notificacion.tipo),
                    color: _colorPorTipo(notificacion.tipo),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificacion.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: notificacion.leido
                              ? Colors.grey[700]
                              : _darkNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notificacion.mensaje,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatearFecha(notificacion.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notificacion.leido) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeccionHeader extends StatelessWidget {
  final String texto;
  const _SeccionHeader(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }
}