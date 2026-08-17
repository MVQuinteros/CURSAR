import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_vocacional_model.dart';
import '../models/oferta_model.dart';

class TestService {
  CollectionReference _testRef(String subcol) =>
      FirebaseFirestore.instance
          .collection('testVocacional')
          .doc('data')
          .collection(subcol);

  Future<List<PreguntaModel>> obtenerPreguntas() async {
    final snapshot = await _testRef('preguntas').get();
    return snapshot.docs
        .map((doc) =>
            PreguntaModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> guardarRespuesta(RespuestaModel respuesta) async {
    await _testRef('respuestas')
        .doc(respuesta.respuestaId)
        .set(respuesta.toMap());
  }

  Future<void> guardarResultado(ResultadoModel resultado) async {
    await _testRef('resultados')
        .doc(resultado.resultadoId)
        .set(resultado.toMap());
  }

  Future<List<ResultadoModel>> obtenerResultados(String userUid) async {
    final snapshot =
        await _testRef('resultados').where('userUid', isEqualTo: userUid).get();
    return snapshot.docs
        .map((doc) =>
            ResultadoModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  String _obtenerNombreArea(AreaInteres area) {
    switch (area) {
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

  AreaInteres calcularResultado(List<int?> selecciones) {
    final conteo = <AreaInteres, int>{
      AreaInteres.tecnologia: 0,
      AreaInteres.salud: 0,
      AreaInteres.educacion: 0,
      AreaInteres.creativa: 0,
    };

    for (final seleccion in selecciones) {
      if (seleccion == null) continue;
      switch (seleccion) {
        case 0:
          conteo[AreaInteres.tecnologia] = conteo[AreaInteres.tecnologia]! + 1;
          break;
        case 1:
          conteo[AreaInteres.salud] = conteo[AreaInteres.salud]! + 1;
          break;
        case 2:
          conteo[AreaInteres.educacion] = conteo[AreaInteres.educacion]! + 1;
          break;
        case 3:
          conteo[AreaInteres.creativa] = conteo[AreaInteres.creativa]! + 1;
          break;
      }
    }

    AreaInteres maxArea = AreaInteres.tecnologia;
    int maxValor = 0;
    for (final entry in conteo.entries) {
      if (entry.value > maxValor) {
        maxValor = entry.value;
        maxArea = entry.key;
      }
    }

    return maxArea;
  }

  Map<AreaInteres, int> obtenerConteoAreas(List<int?> selecciones) {
    final conteo = <AreaInteres, int>{
      AreaInteres.tecnologia: 0,
      AreaInteres.salud: 0,
      AreaInteres.educacion: 0,
      AreaInteres.creativa: 0,
    };

    for (final seleccion in selecciones) {
      if (seleccion == null) continue;
      switch (seleccion) {
        case 0:
          conteo[AreaInteres.tecnologia] = conteo[AreaInteres.tecnologia]! + 1;
          break;
        case 1:
          conteo[AreaInteres.salud] = conteo[AreaInteres.salud]! + 1;
          break;
        case 2:
          conteo[AreaInteres.educacion] = conteo[AreaInteres.educacion]! + 1;
          break;
        case 3:
          conteo[AreaInteres.creativa] = conteo[AreaInteres.creativa]! + 1;
          break;
      }
    }

    return conteo;
  }

  Future<List<OfertaModel>> obtenerOfertasPorArea(AreaInteres area) async {
    final nombreArea = _obtenerNombreArea(area);
    final snapshot = await FirebaseFirestore.instance
        .collection('ofertas')
        .where('area', isEqualTo: nombreArea)
        .where('aprobada', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => OfertaModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> guardarResultadoCompleto({
    required String userUid,
    required AreaInteres areaInteres,
    required List<String> ofertasRecomendadas,
  }) async {
    final resultado = {
      'userUid': userUid,
      'areaInteres': _obtenerNombreArea(areaInteres),
      'ofertasRecomendadas': ofertasRecomendadas,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('testVocacional')
        .doc('data')
        .collection('resultados')
        .doc(userUid)
        .set(resultado, SetOptions(merge: true));
  }

  Future<bool> usuarioTieneResultado(String userUid) async {
    final doc = await FirebaseFirestore.instance
        .collection('testVocacional')
        .doc('data')
        .collection('resultados')
        .doc(userUid)
        .get();
    return doc.exists;
  }
}
