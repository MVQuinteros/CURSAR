class PreferenciasModel {
  final String localidad;
  final int radioBusqueda;
  final String modalidad;
  final String tipoInstitucion;

  const PreferenciasModel({
    this.localidad = '',
    this.radioBusqueda = 20,
    this.modalidad = 'Presencial y Online',
    this.tipoInstitucion = 'Pública y Privada',
  });

  factory PreferenciasModel.fromMap(Map<String, dynamic> map) {
    return PreferenciasModel(
      localidad: map['localidad']?.toString() ?? '',
      radioBusqueda: (map['radioBusqueda'] as num?)?.toInt() ?? 20,
      modalidad: map['modalidad']?.toString() ?? 'Presencial y Online',
      tipoInstitucion:
          map['tipoInstitucion']?.toString() ?? 'Pública y Privada',
    );
  }

  PreferenciasModel copyWith({
    String? localidad,
    int? radioBusqueda,
    String? modalidad,
    String? tipoInstitucion,
  }) {
    return PreferenciasModel(
      localidad: localidad ?? this.localidad,
      radioBusqueda: radioBusqueda ?? this.radioBusqueda,
      modalidad: modalidad ?? this.modalidad,
      tipoInstitucion: tipoInstitucion ?? this.tipoInstitucion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localidad': localidad,
      'radioBusqueda': radioBusqueda,
      'modalidad': modalidad,
      'tipoInstitucion': tipoInstitucion,
    };
  }
}