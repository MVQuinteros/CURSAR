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
    this.latitud,
    this.longitud,
    this.estado = 'pendiente',
    this.createdAt,
  });

  factory InstitucionModel.fromMap(String id, Map<String, dynamic> map) {
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
      latitud: (map['ubicacion'] as dynamic)?.latitude,
      longitud: (map['ubicacion'] as dynamic)?.longitude,
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
      'ubicacion': (latitud != null && longitud != null)
          ? GeoPoint(latitud!, longitud!)
          : null,
      'estado': estado,
      'createdAt': createdAt,
    };
  }
}
