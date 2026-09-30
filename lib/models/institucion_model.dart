import 'package:cloud_firestore/cloud_firestore.dart';

class InstitucionModel {
  final String institucionUid;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String ciudad;
  final String provincia;
  final String telefono;
  final String email;
  final String sitioWeb;
  final String logoURL;
  final String logoAsset;
  final String fotoCampus;

  /// Cuando es true el logo se muestra completo (contain) sobre la superficie
  /// del tema, en vez de recortarse (cover). Necesario para logos verticales,
  /// que en un CircleAvatar pierden los bordes superior e inferior.
  final bool logoContained;

  final double? latitud;
  final double? longitud;
  final String estado;
  final DateTime? createdAt;

  InstitucionModel({
    required this.institucionUid,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.ciudad,
    required this.provincia,
    required this.telefono,
    required this.email,
    required this.sitioWeb,
    required this.logoURL,
    this.logoAsset = '',
    this.fotoCampus = '',
    this.logoContained = false,
    this.latitud,
    this.longitud,
    this.estado = 'pendiente',
    this.createdAt,
  });

  /// Resuelve las coordenadas tolerando los tres formatos que hay en la base.
  ///
  /// El canónico es `ubicacion` como GeoPoint, que es lo que escribe [toMap] y
  /// lo que usa la semilla. Pero hay documentos cargados o editados a mano en la
  /// consola de Firebase con `latitud` y `longitud` como números sueltos, y con
  /// `ubicacion` ausente o vacío. Leyendo solo el GeoPoint, esas instituciones
  /// llegaban con latitud y longitud en null y el mapa las descartaba en
  /// silencio, sin error ni log: aparecían todas menos las que faltaban.
  ///
  /// Por eso el GeoPoint gana si está, y si no se cae a los campos sueltos.
  /// Aceptar además un mapa anidado cubre los docs importados desde un JSON.
  /// Las coordenadas se descartan si vienen incompletas o fuera de rango, porque
  /// un par incompleto no sirve y uno con latitud y longitud intercambiadas
  /// dibujaría el marcador en el mar.
  static GeoPoint? _readCoordinates(Map<String, dynamic> map) {
    final ubicacion = map['ubicacion'];

    if (ubicacion is GeoPoint) return ubicacion;
    if (ubicacion is Map) {
      final anidada = _buildGeoPoint(
        ubicacion['latitude'] ?? ubicacion['lat'],
        ubicacion['longitude'] ?? ubicacion['lng'],
      );
      if (anidada != null) return anidada;
    }

    return _buildGeoPoint(map['latitud'], map['longitud']);
  }

  static GeoPoint? _buildGeoPoint(dynamic lat, dynamic lng) {
    final la = _toDouble(lat);
    final lo = _toDouble(lng);
    if (la == null || lo == null) return null;
    if (la < -90 || la > 90 || lo < -180 || lo > 180) return null;
    return GeoPoint(la, lo);
  }

  static double? _toDouble(dynamic valor) {
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.tryParse(valor.trim());
    return null;
  }

  factory InstitucionModel.fromMap(String id, Map<String, dynamic> map) {
    final coordenadas = _readCoordinates(map);

    return InstitucionModel(
      institucionUid: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      direccion: map['direccion'] ?? '',
      ciudad: map['ciudad'] ?? '',
      provincia: map['provincia'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      sitioWeb: map['sitioWeb'] ?? '',
      logoURL: map['logoURL'] ?? '',
      logoAsset: map['logoAsset'] ?? '',
      fotoCampus: map['fotoCampus'] ?? '',
      logoContained: map['logoContained'] as bool? ?? false,
      latitud: coordenadas?.latitude,
      longitud: coordenadas?.longitude,
      estado: map['estado'] ?? 'pendiente',
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'institucionUid': institucionUid,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'ciudad': ciudad,
      'provincia': provincia,
      'telefono': telefono,
      'email': email,
      'sitioWeb': sitioWeb,
      'logoURL': logoURL,
      'logoAsset': logoAsset,
      'fotoCampus': fotoCampus,
      'logoContained': logoContained,
      'ubicacion': (latitud != null && longitud != null)
          ? GeoPoint(latitud!, longitud!)
          : null,
      'estado': estado,
      'createdAt': createdAt,
    };
  }
}
