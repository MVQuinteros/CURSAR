import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_vocacional_model.dart';
import '../models/oferta_model.dart';
import '../models/institucion_model.dart';
import 'filtro_zonas.dart';

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

  /// Arma las ofertas para que la IA las use como unica fuente (grounding).
  ///
  /// Se resuelve el NOMBRE real de la institucion y su ciudad: `OfertaModel`
  /// solo trae `institucionUid`, y si se le manda ese uid opaco el modelo
  /// termina inventando el lugar donde se estudia. El texto que devuelve este
  /// metodo es el MISMO que va al `enum` del schema del perfil, asi que lo que
  /// responde el modelo se puede mapear 1 a 1 contra la base.
  Future<List<String>> formatearParaIA(
    List<OfertaModel> ofertas, {
    int limite = 15,
  }) async {
    if (ofertas.isEmpty) return const [];

    final instituciones = await _institucionesPorUid();
    final seleccionadas = ofertas.take(limite).toList();

    // Las del area de influencia primero: el modelo tiende a elegirlas sin que
    // el prompt nombre ninguna institucion (nombrarlas es lo que antes lo
    // llevaba a inventar universidades "tipicas" del conurbano).
    seleccionadas.sort((a, b) {
      final ia = instituciones[a.institucionUid];
      final ib = instituciones[b.institucionUid];
      final za = ia != null && FiltroZonas.esDeZonaObjetivo(ia);
      final zb = ib != null && FiltroZonas.esDeZonaObjetivo(ib);
      if (za == zb) return 0;
      return za ? -1 : 1;
    });

    // Deduplicado: el `enum` del schema no admite valores repetidos.
    final labels = <String>[];
    for (final o in seleccionadas) {
      final inst = instituciones[o.institucionUid];
      final nombre = (inst?.nombre ?? '').trim();
      final ciudad = (inst?.ciudad ?? '').trim();
      final label = nombre.isEmpty
          ? o.nombre
          : '${o.nombre} — $nombre${ciudad.isEmpty ? '' : ' ($ciudad)'}';
      if (!labels.contains(label)) labels.add(label);
    }
    return labels;
  }

  /// Mapa uid -> nombre real de la institucion, para poder mostrar el nombre
  /// en la UI en lugar del uid. Sólo resuelve los uids que se le piden.
  Future<Map<String, String>> nombresDeInstituciones(
    Iterable<String> uids,
  ) async {
    final pedidos =
        uids.map((u) => u.trim()).where((u) => u.isNotEmpty).toSet();
    if (pedidos.isEmpty) return const {};

    final instituciones = await _institucionesPorUid();
    final nombres = <String, String>{};
    for (final uid in pedidos) {
      final nombre = (instituciones[uid]?.nombre ?? '').trim();
      if (nombre.isNotEmpty) nombres[uid] = nombre;
    }
    return nombres;
  }

  /// Mapa uid -> institucion. Se traen todas de una (son pocas) para no topar
  /// con el limite de 10 valores de `whereIn`.
  Future<Map<String, InstitucionModel>> _institucionesPorUid() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('instituciones').get();
    return {
      for (final doc in snapshot.docs)
        doc.id: InstitucionModel.fromMap(doc.id, doc.data()),
    };
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
