class OfertaModel {
  final String ofertaId;
  final String institucionUid;
  final String nombre;
  final String descripcion;
  final String area;
  final String nivel;

  /// Puede ser fraccionario (1.5, 2.5 años) en ofertas a distancia.
  /// 0 significa "duración no confirmada": la UI no la muestra.
  final num duracionAnios;
  final String modalidad;
  final String salidaLaboral;
  final String requisitos;
  final String tag;
  final bool aprobada;
  final DateTime? createdAt;

  OfertaModel({
    required this.ofertaId,
    required this.institucionUid,
    required this.nombre,
    required this.descripcion,
    required this.area,
    required this.nivel,
    required this.duracionAnios,
    required this.modalidad,
    required this.salidaLaboral,
    required this.requisitos,
    required this.tag,
    this.aprobada = false,
    this.createdAt,
  });

  /// Texto listo para mostrar la duración, o cadena vacía si no está
  /// confirmada. Ej.: "4 años", "1 año", "2,5 años", "".
  String get duracionTexto {
    if (duracionAnios <= 0) return '';
    final entero = duracionAnios == duracionAnios.roundToDouble();
    final numero = entero
        ? duracionAnios.round().toString()
        : duracionAnios.toStringAsFixed(1).replaceAll('.', ',');
    return '$numero ${duracionAnios == 1 ? 'año' : 'años'}';
  }

  /// Indica si la oferta tiene al menos un dato que mostrar en la ficha.
  bool get tieneDescripcion => descripcion.trim().isNotEmpty;
  bool get tieneSalidaLaboral => salidaLaboral.trim().isNotEmpty;
  bool get tieneTag => tag.trim().isNotEmpty;
  bool get tieneNivel => nivel.trim().isNotEmpty;
  bool get tieneModalidad => modalidad.trim().isNotEmpty;

  factory OfertaModel.fromMap(String id, Map<String, dynamic> map) {
    return OfertaModel(
      ofertaId: id,
      institucionUid: map['institucionUid']?.toString() ?? '',
      nombre: map['nombre']?.toString() ?? '',
      descripcion: map['descripcion']?.toString() ?? '',
      area: map['area']?.toString() ?? '',
      nivel: map['nivel']?.toString() ?? '',
      duracionAnios: _aNumero(map['duracionAnios']),
      modalidad: map['modalidad']?.toString() ?? '',
      salidaLaboral: map['salidaLaboral']?.toString() ?? '',
      requisitos: map['requisitos']?.toString() ?? '',
      tag: map['tag']?.toString() ?? '',
      aprobada: map['aprobada'] ?? false,
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  static num _aNumero(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'ofertaId': ofertaId,
      'institucionUid': institucionUid,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'nivel': nivel,
      'duracionAnios': duracionAnios,
      'modalidad': modalidad,
      'salidaLaboral': salidaLaboral,
      'requisitos': requisitos,
      'tag': tag,
      'aprobada': aprobada,
      'createdAt': createdAt,
    };
  }
}
