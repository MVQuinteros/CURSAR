import 'package:flutter/material.dart';

enum AreaInteres {
  tecnologia,
  salud,
  educacion,
  creativa,
}

extension AreaInteresExtension on AreaInteres {
  String get nombre {
    switch (this) {
      case AreaInteres.tecnologia:
        return 'Tecnología';
      case AreaInteres.salud:
        return 'Salud';
      case AreaInteres.educacion:
        return 'Educación';
      case AreaInteres.creativa:
        return 'Creativa';
    }
  }

  String get descripcion {
    switch (this) {
      case AreaInteres.tecnologia:
        return 'Te apasiona resolver problemas lógicos, la tecnología y los sistemas.';
      case AreaInteres.salud:
        return 'Te interesan las ciencias de la salud y ayudar a las personas.';
      case AreaInteres.educacion:
        return 'Disfrutás enseñar, liderar y organizar equipos.';
      case AreaInteres.creativa:
        return 'Sos creativo/a, te gusta diseñar y expresarte.';
    }
  }

  IconData get icono {
    switch (this) {
      case AreaInteres.tecnologia:
        return Icons.computer;
      case AreaInteres.salud:
        return Icons.local_hospital;
      case AreaInteres.educacion:
        return Icons.school;
      case AreaInteres.creativa:
        return Icons.palette;
    }
  }

  Color get color {
    switch (this) {
      case AreaInteres.tecnologia:
        return const Color(0xFF2196F3);
      case AreaInteres.salud:
        return const Color(0xFF4CAF50);
      case AreaInteres.educacion:
        return const Color(0xFFFF9800);
      case AreaInteres.creativa:
        return const Color(0xFF9C27B0);
    }
  }

  String get imagen {
    switch (this) {
      case AreaInteres.tecnologia:
        return '💻';
      case AreaInteres.salud:
        return '🏥';
      case AreaInteres.educacion:
        return '📚';
      case AreaInteres.creativa:
        return '🎨';
    }
  }
}

class PreguntaModel {
  final String preguntaId;
  final String texto;
  final List<String> opciones;

  PreguntaModel({
    required this.preguntaId,
    required this.texto,
    required this.opciones,
  });

  factory PreguntaModel.fromMap(String id, Map<String, dynamic> map) {
    return PreguntaModel(
      preguntaId: id,
      texto: map['texto'] ?? '',
      opciones: List<String>.from(map['opciones'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preguntaId': preguntaId,
      'texto': texto,
      'opciones': opciones,
    };
  }
}

class RespuestaModel {
  final String respuestaId;
  final String userUid;
  final String preguntaId;
  final String opcionSeleccionada;
  final DateTime? createdAt;

  RespuestaModel({
    required this.respuestaId,
    required this.userUid,
    required this.preguntaId,
    required this.opcionSeleccionada,
    this.createdAt,
  });

  factory RespuestaModel.fromMap(String id, Map<String, dynamic> map) {
    return RespuestaModel(
      respuestaId: id,
      userUid: map['userUid'] ?? '',
      preguntaId: map['preguntaId'] ?? '',
      opcionSeleccionada: map['opcionSeleccionada'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'respuestaId': respuestaId,
      'userUid': userUid,
      'preguntaId': preguntaId,
      'opcionSeleccionada': opcionSeleccionada,
      'createdAt': createdAt,
    };
  }
}

class ResultadoModel {
  final String resultadoId;
  final String userUid;
  final String areaInteres;
  final List<String> ofertasRecomendadas;
  final DateTime? createdAt;

  ResultadoModel({
    required this.resultadoId,
    required this.userUid,
    required this.areaInteres,
    required this.ofertasRecomendadas,
    this.createdAt,
  });

  factory ResultadoModel.fromMap(String id, Map<String, dynamic> map) {
    return ResultadoModel(
      resultadoId: id,
      userUid: map['userUid'] ?? '',
      areaInteres: map['areaInteres'] ?? '',
      ofertasRecomendadas: List<String>.from(map['ofertasRecomendadas'] ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resultadoId': resultadoId,
      'userUid': userUid,
      'areaInteres': areaInteres,
      'ofertasRecomendadas': ofertasRecomendadas,
      'createdAt': createdAt,
    };
  }
}
