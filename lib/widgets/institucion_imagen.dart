import 'package:flutter/material.dart';

import '../models/institucion_model.dart';
import '../theme/app_theme.dart';

/// Resuelve la imagen de una institucion priorizando el asset local embebido
/// (descargado del sitio oficial) y usando la URL remota solo como fallback.
/// Asi la UI no depende de la red ni muestra flashes de carga.
class InstitucionImagen extends StatelessWidget {
  const InstitucionImagen({
    super.key,
    required this.institucion,
    this.usarFotoCampus = false,
    this.fit = BoxFit.cover,
    this.ancho,
    this.alto,
    this.placeholder,
  });

  final InstitucionModel institucion;
  final bool usarFotoCampus;
  final BoxFit fit;
  final double? ancho;
  final double? alto;
  final Widget? placeholder;

  String get _ruta {
    final ruta = usarFotoCampus ? institucion.fotoCampus : institucion.logoAsset;
    return ruta.trim();
  }

  String get _remoto => institucion.logoURL.trim();

  BoxFit get _ajuste => institucion.logoContained ? BoxFit.contain : fit;

  @override
  Widget build(BuildContext context) {
    final ruta = _ruta;
    // Un logo vertical recortado con cover pierde los bordes, que es justo
    // donde suele estar el texto. Para esos casos lo mostramos completo
    // sobre la superficie del tema (blanco en claro, oscuro en dark).
    final contenido = (ruta.isNotEmpty)
        ? Image.asset(
            ruta,
            width: ancho,
            height: alto,
            fit: _ajuste,
            errorBuilder: (_, _, _) => _fallback(),
          )
        : (_remoto.isNotEmpty
            ? Image.network(
                _remoto,
                width: ancho,
                height: alto,
                fit: _ajuste,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback());

    if (!institucion.logoContained) return contenido;
    return ColoredBox(
      color: context.colors.bgSurface,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: contenido,
      ),
    );
  }

  Widget _fallback() => placeholder ?? const Icon(Icons.school);
}
