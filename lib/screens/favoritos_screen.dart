import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/institucion_model.dart';
import '../models/oferta_model.dart';
import '../services/favorito_service.dart';
import '../theme/app_theme.dart';

class _FavoritoItem {
  final String favoriteDocId;
  final OfertaModel? oferta;
  final InstitucionModel? institucion;

  const _FavoritoItem({
    required this.favoriteDocId,
    this.oferta,
    this.institucion,
  });
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color _azulGradienteInicio = Color(0xFF1B74E4);
  static const Color _azulGradienteFin = Color(0xFF58B2FF);

  final FavoritoService _favoritoService = FavoritoService();
  final Map<String, InstitucionModel> _instCache = {};

  void _navegar(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/test');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  Future<InstitucionModel?> _obtenerInstitucion(String uid) async {
    if (uid.isEmpty) return null;
    if (_instCache.containsKey(uid)) return _instCache[uid];
    final doc = await FirebaseFirestore.instance
        .collection('instituciones')
        .doc(uid)
        .get();
    InstitucionModel? inst;
    if (doc.exists) {
      inst = InstitucionModel.fromMap(doc.id, doc.data()!);
      _instCache[uid] = inst;
    }
    return inst;
  }

  Future<List<_FavoritoItem>> _resolverFavoritos(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final items = <_FavoritoItem>[];
    for (final doc in docs) {
      try {
        items.add(await _construirItem(doc));
      } catch (e) {
        debugPrint('Favoritos: se omitió el favorito ${doc.id} por dato inválido: $e');
      }
    }
    return items;
  }

  Future<_FavoritoItem> _construirItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();

    final ofertaId = _extraerOfertaId(data);
    final institucionUid = _inferirInstitucionUid(data, ofertaId);

    OfertaModel? oferta;
    if (ofertaId != null && ofertaId.isNotEmpty) {
      final ofertaDoc = await FirebaseFirestore.instance
          .collection('ofertas')
          .doc(ofertaId)
          .get();
      if (ofertaDoc.exists) {
        oferta = OfertaModel.fromMap(ofertaDoc.id, ofertaDoc.data()!);
      }
    }

    final inst = await _obtenerInstitucion(institucionUid ?? '');

    return _FavoritoItem(
      favoriteDocId: doc.id,
      oferta: oferta,
      institucion: inst,
    );
  }

  /// Extrae el `ofertaId` aceptando el formato viejo (String plano) y el nuevo (Map).
  String? _extraerOfertaId(Map<String, dynamic> data) {
    final raw = data['ofertaId'] ?? data['oferta_id'];
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? null : t;
    }
    if (raw is Map) {
      final inner = raw['ofertaId'] ?? raw['id'];
      if (inner is String) return inner.trim().isEmpty ? null : inner.trim();
    }
    return null;
  }

  /// Devuelve el `institucionUid`: usa el campo directo si existe; si no,
  /// lo infiere del `ofertaId` (estructura `oferta_<institucion>_<num>`).
  String? _inferirInstitucionUid(Map<String, dynamic> data, String? ofertaId) {
    final directo = data['institucionUid'] ?? data['institucion_uid'];
    if (directo is String && directo.trim().isNotEmpty) return directo.trim();

    if (ofertaId != null && ofertaId.isNotEmpty) {
      final partes = ofertaId.split('_');
      if (partes.length >= 2 && partes[1].isNotEmpty) return partes[1];
    }
    return null;
  }

  Future<void> _quitarFavorito(_FavoritoItem item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _favoritoService.eliminarFavorito(user.uid, item.favoriteDocId);
  }

  void _abrirFavorito(_FavoritoItem item) {
    final inst = item.institucion;
    if (inst == null) return;
    Navigator.pushNamed(
      context,
      '/institucion',
      arguments: {
        'institucionUid': inst.institucionUid,
        'ofertaId': item.oferta?.ofertaId,
      },
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 28,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_azulGradienteInicio, _azulGradienteFin],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _volver,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const Icon(Icons.favorite, color: Colors.white, size: 40),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mis favoritos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Carreras e instituciones que te interesan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _volver() {
    Navigator.pop(context);
  }

  String _tituloCarrera(_FavoritoItem item) {
    return item.oferta?.nombre ?? 'Carrera';
  }

  String _nombreInstitucion(_FavoritoItem item) {
    return item.institucion?.nombre ?? 'Institución';
  }

  List<String> _detalles(_FavoritoItem item) {
    final oferta = item.oferta;
    if (oferta != null) {
      return [
        if (oferta.duracionAnios > 0) '${oferta.duracionAnios} años',
        if (oferta.modalidad.isNotEmpty) oferta.modalidad,
      ];
    }
    return [];
  }

  Widget _imagenInstitucion(_FavoritoItem item) {
    final inst = item.institucion;
    final logoURL = inst?.logoURL ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: logoURL.isNotEmpty
            ? Image.network(
                logoURL,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  );
                },
                errorBuilder: (_, _, _) => _imagenPlaceholder(),
              )
            : _imagenPlaceholder(),
      ),
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.school,
        size: 28,
        color: Colors.grey,
      ),
    );
  }

  Widget _cardFavorito(_FavoritoItem item) {
    final detalles = _detalles(item);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _abrirFavorito(item),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _imagenInstitucion(item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tituloCarrera(item),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _nombreInstitucion(item),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (detalles.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: context.colors.iconNormal,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              detalles.join(' • '),
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _quitarFavorito(item),
                icon: const Icon(Icons.favorite, color: Colors.red),
                tooltip: 'Quitar de favoritos',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListaFavoritos(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    return FutureBuilder<List<_FavoritoItem>>(
      future: _resolverFavoritos(docs),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return _buildVacio();
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            // Resiliencia: si este favorito no se pudo resolver (sin oferta
            // ni institución), se omite el card en lugar de romper la lista.
            if (item.oferta == null && item.institucion == null) {
              return const SizedBox.shrink();
            }
            return _cardFavorito(item);
          },
        );
      },
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 56,
              color: context.colors.iconNormal,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tenés favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guardá carreras e instituciones que te interesan para verlas acá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConectando() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off,
              size: 40,
              color: context.colors.iconNormal,
            ),
            const SizedBox(height: 16),
            Text(
              'Reconectando…',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Se está restaurando la conexión. Tus favoritos van a aparecer automáticamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Text(
          'Iniciá sesión para ver tus favoritos',
          style: TextStyle(color: context.colors.textSecondary),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: _favoritoService.favoritosStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildConectando();
        }
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _buildVacio();
        }
        return _buildListaFavoritos(
          docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgMain,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: _navegar,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: const Color(0xFF757575),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}