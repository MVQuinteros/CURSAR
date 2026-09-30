import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/institucion_model.dart';
import '../models/oferta_model.dart';
import '../services/favorito_service.dart';
import '../theme/app_theme.dart';
import '../widgets/institucion_imagen.dart';

class _FavoritoItem {
  final String favoriteDocId;
  final OfertaModel? oferta;
  final InstitucionModel? institucion;
  final bool esInstitucion;

  const _FavoritoItem({
    required this.favoriteDocId,
    this.oferta,
    this.institucion,
    this.esInstitucion = false,
  });
}

/// Pestana activa del filtro de favoritos.
enum _FiltroFavoritos { carreras, instituciones }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color _azulGradienteInicio = Color(0xFF1B74E4);
  static const Color _azulGradienteFin = Color(0xFF58B2FF);
  static const Color _celesteFiltro = Color(0xFFE3F2FD);
  static const Color _blancoSegmento = Color(0xFFFFFFFF);

  final FavoritoService _favoritoService = FavoritoService();
  final Map<String, InstitucionModel> _instCache = {};

  /// Items ya resueltos, por id de documento de favorito. Evita volver a pedir
  /// a Firestore lo que ya se sabe cuando cambia la pestana activa.
  final Map<String, _FavoritoItem> _itemsCache = {};

  _FiltroFavoritos _filtro = _FiltroFavoritos.carreras;

  /// La pestana se autoelige una sola vez, con el primer lote de favoritos con
  /// contenido. Despues el usuario manda.
  bool _yaElijoPestana = false;

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

  /// Resuelve todos los favoritos en paralelo. Cada item necesita a lo sumo dos
  /// lecturas (oferta + institucion), asi que en vez de esperarlas de a una se
  /// lanzan juntas con [Future.wait].
  Future<List<_FavoritoItem>> _resolverFavoritos(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final resueltos = await Future.wait(
      docs.map((doc) async {
        try {
          return await _construirItem(doc);
        } catch (e) {
          debugPrint('Favoritos: se omitió el favorito ${doc.id} por dato inválido: $e');
          return null;
        }
      }),
    );
    return resueltos.whereType<_FavoritoItem>().toList();
  }

  Future<_FavoritoItem> _construirItem(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final cacheado = _itemsCache[doc.id];
    if (cacheado != null) return cacheado;

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

    final item = _FavoritoItem(
      favoriteDocId: doc.id,
      oferta: oferta,
      institucion: inst,
      esInstitucion: FavoritoService.esFavoritoDeInstitucion(doc.id, data),
    );
    _itemsCache[doc.id] = item;
    return item;
  }

  /// Si el documento de favorito corresponde a una institucion.
  bool _esDocInstitucion(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      FavoritoService.esFavoritoDeInstitucion(doc.id, doc.data());

  /// Si el usuario solo guardo una de las dos categorias, arranca en esa.
  /// Se resuelve una sola vez y con `addPostFrameCallback` porque no se puede
  /// llamar a `setState` mientras se construye.
  void _asegurarPestanaInicial(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (_yaElijoPestana || docs.isEmpty) return;
    _yaElijoPestana = true;

    if (docs.any((d) => !_esDocInstitucion(d))) return;

    final destino = _filtro == _FiltroFavoritos.carreras
        ? _FiltroFavoritos.instituciones
        : _FiltroFavoritos.carreras;
    if (destino == _FiltroFavoritos.instituciones &&
        !docs.any(_esDocInstitucion)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _filtro = destino);
    });
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
    _itemsCache.remove(item.favoriteDocId);
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
    if (item.oferta != null) return item.oferta!.nombre;
    return item.institucion?.nombre ?? 'Carrera';
  }

  /// Subtítulo de la tarjeta. En una carrera muestra la institución que la
  /// ofrece; en un favorito de institución el nombre ya está en el título, así
  /// que se aprovecha para ubicar al usuario.
  String _nombreInstitucion(_FavoritoItem item) {
    final inst = item.institucion;
    if (item.esInstitucion) {
      final ciudad = inst?.ciudad.trim() ?? '';
      if (ciudad.isNotEmpty) return ciudad;
      final provincia = inst?.provincia.trim() ?? '';
      if (provincia.isNotEmpty) return provincia;
      return 'Ubicación no informada';
    }
    return inst?.nombre ?? 'Institución';
  }

  List<String> _detalles(_FavoritoItem item) {
    final oferta = item.oferta;
    if (oferta != null) {
      return [
        if (oferta.duracionTexto.isNotEmpty) oferta.duracionTexto,
        if (oferta.modalidad.isNotEmpty) oferta.modalidad,
      ];
    }
    return [];
  }

  Widget _imagenInstitucion(_FavoritoItem item) {
    final inst = item.institucion;
    if (inst == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 72, height: 72, child: _imagenPlaceholder()),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: InstitucionImagen(
          institucion: inst,
          placeholder: _imagenPlaceholder(),
        ),
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

  /// Control segmentado de dos opciones. El relleno de la pestana activa se
  /// desliza con `AnimatedAlign`; el contenedor usa celeste en claro y un tinte
  /// del acento en oscuro, que es lo unico que se ve bien en los dos temas.
  Widget _buildFiltro() {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: esOscuro
            ? context.colors.accentPrimary.withValues(alpha: 0.12)
            : _celesteFiltro,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final anchoSegmento = constraints.maxWidth / 2;
          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: _filtro == _FiltroFavoritos.carreras
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: anchoSegmento,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _azulGradienteInicio,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _pestana(_FiltroFavoritos.carreras, 'Carreras'),
                  ),
                  Expanded(
                    child: _pestana(
                      _FiltroFavoritos.instituciones,
                      'Instituciones',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pestana(_FiltroFavoritos filtro, String etiqueta) {
    final activa = _filtro == filtro;
    return Semantics(
      button: true,
      selected: activa,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _filtro = filtro),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 14,
              fontWeight: activa ? FontWeight.w600 : FontWeight.w500,
              color: activa ? _blancoSegmento : context.colors.textSecondary,
            ),
            child: Text(
              etiqueta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  /// Título de la sección y conteo de lo que hay en la pestana activa.
  Widget _buildResumen(int cantidad) {
    final esCarreras = _filtro == _FiltroFavoritos.carreras;
    final sustantivo = esCarreras
        ? (cantidad == 1 ? 'carrera' : 'carreras')
        : (cantidad == 1 ? 'institución' : 'instituciones');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          esCarreras ? 'Mis carreras guardadas' : 'Mis instituciones guardadas',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$cantidad $sustantivo',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Estado vacio de una pestana en concreto. Es distinto del vacio global:
  /// el usuario tiene favoritos, solo que de la otra categoria.
  Widget _buildVacioPestana() {
    final esCarreras = _filtro == _FiltroFavoritos.carreras;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              esCarreras
                  ? Icons.menu_book_outlined
                  : Icons.account_balance_outlined,
              size: 48,
              color: context.colors.iconNormal,
            ),
            const SizedBox(height: 14),
            Text(
              esCarreras
                  ? 'No guardaste carreras'
                  : 'No guardaste instituciones',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              esCarreras
                  ? 'Tocá el corazón en una carrera y va a aparecer en esta pestaña.'
                  : 'Tocá el corazón en una institución y va a aparecer en esta pestaña.',
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

  Widget _buildListaFavoritos(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    _asegurarPestanaInicial(docs);

    // Se filtra sobre los documentos crudos, no sobre los items resueltos: el
    // tipo de favorito ya esta en el propio documento, asi que cambiar de
    // pestana no obliga a volver a leer de Firestore lo de la otra categoria.
    final esInstituciones = _filtro == _FiltroFavoritos.instituciones;
    final docsFiltrados =
        docs.where((d) => _esDocInstitucion(d) == esInstituciones).toList();

    return FutureBuilder<List<_FavoritoItem>>(
      future: _resolverFavoritos(docsFiltrados),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Los que no se pudieron resolver (ni oferta ni institucion) se
        // descartan aca para que el conteo y el itemCount coincidan con las
        // tarjetas que se ven.
        final items = (snapshot.data ?? const <_FavoritoItem>[])
            .where((i) => i.oferta != null || i.institucion != null)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildFiltro(),
            ),
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: _buildResumen(items.length),
              ),
            Expanded(
              child: items.isEmpty
                  ? _buildVacioPestana()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _cardFavorito(items[index]),
                    ),
            ),
          ],
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