import '../models/institucion_model.dart';

/// Filtro temporal por zona. Mientras la base tenga instituciones de todo el
/// pais, el inicio y "Explorar por institucion" muestran solo las del area de
/// influencia de la app: San Miguel, Jose C. Paz y Malvinas Argentinas.
///
/// Se decide por el campo ciudad, que es el unico que distingue a las
/// instituciones entre si: provincia dice "Buenos Aires" para todas.
///
/// Para revertir y volver a mostrar todo, poner soloZonasObjetivo en false.
class FiltroZonas {
  const FiltroZonas._();

  static const bool soloZonasObjetivo = true;

  /// Los docs que no son instituciones reales (marcadores de parches).
  static const Set<String> _uidsTecnicos = {
    'logos_storage_v1',
    'eliminar_isft180_v1',
    'patch_assets_locales_v1',
    'patch_assets_locales_v2',
    'patch_assets_locales_v3',
    'patch_assets_locales_v4',
    'patch_assets_locales_v5',
    'patch_assets_locales_v6',
  };

  /// Instituciones reales que por ahora no se muestran, sin borrarlas de la
  /// base. Pendiente de eliminar de Firestore cuando zanjemos la lista.
  static const Set<String> _uidsOcultos = {
    'ism_sanmiguel',
  };

  static const List<String> _patronesZona = [
    'san miguel',
    'jose c. paz',
    'jose c paz',
    'malvinas',
    'los polvorines',
  ];

  static String _normalizar(String texto) {
    return texto
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _esUidTecnico(String uid) {
    if (_uidsTecnicos.contains(uid)) return true;
    return uid.startsWith('patch_') ||
        uid.startsWith('logos_') ||
        uid.startsWith('eliminar_');
  }

  static bool esDeZonaObjetivo(InstitucionModel inst) {
    final ciudad = _normalizar(inst.ciudad);
    return _patronesZona.any(ciudad.contains);
  }

  /// Filtra la lista que devuelve la base. Además de la zona, saca los docs
  /// marcadores, que hoy se cuelan en las pantallas como instituciones sin
  /// nombre.
  static List<InstitucionModel> aplicar(List<InstitucionModel> todas) {
    final reales = todas
        .where((i) => !_esUidTecnico(i.institucionUid))
        .where((i) => !_uidsOcultos.contains(i.institucionUid))
        .where((i) => i.nombre.trim().isNotEmpty)
        .toList();

    if (!soloZonasObjetivo) return reales;
    return reales.where(esDeZonaObjetivo).toList();
  }
}
