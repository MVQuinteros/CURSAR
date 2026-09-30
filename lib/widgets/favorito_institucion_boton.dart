import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/favorito_service.dart';
import '../theme/app_theme.dart';

/// Boton de favorito para una institucion completa. Se auto-gestiona: escucha
/// el stream de favoritos del usuario, distingue los documentos de tipo
/// 'institucion' de los de oferta y alterna la escritura sin estado externo.
class FavoritoInstitucionBoton extends StatelessWidget {
  const FavoritoInstitucionBoton({
    super.key,
    required this.institucionUid,
    this.colorInactivo,
  });

  final String institucionUid;

  /// Si es null el corazon inactivo hereda el IconTheme (util en AppBar, donde
  /// el tema ya define el color). Si se pasa, pisa ese color.
  final Color? colorInactivo;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FavoritoService().favoritosStream(user.uid),
      builder: (context, snap) {
        var docId = '';
        for (final doc in snap.data?.docs ?? const <QueryDocumentSnapshot>[]) {
          final data = doc.data();
          if (data is! Map<String, dynamic>) continue;
          if (!FavoritoService.esFavoritoDeInstitucion(doc.id, data)) continue;
          if (data['institucionUid'] == institucionUid) {
            docId = doc.id;
            break;
          }
        }
        final esFavorita = docId.isNotEmpty;

        return IconButton(
          onPressed: () => _toggle(user.uid, docId),
          icon: Icon(
            esFavorita ? Icons.favorite : Icons.favorite_border,
            color: esFavorita
                ? Colors.red
                : (colorInactivo ?? context.colors.iconNormal),
          ),
          tooltip: esFavorita ? 'Quitar de favoritos' : 'Agregar a favoritos',
        );
      },
    );
  }

  Future<void> _toggle(String userUid, String docId) async {
    final service = FavoritoService();
    if (docId.isNotEmpty) {
      await service.eliminarFavorito(userUid, docId);
    } else {
      await service.agregarFavoritoInstitucion(userUid, institucionUid);
    }
  }
}
