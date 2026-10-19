import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Habla con Gemini (Google AI) para el test vocacional: genera las preguntas
/// y, despues, el perfil personalizado del estudiante.
///
/// Se llama a la REST API directamente con `http` (que ya es dependencia del
/// proyecto) en lugar de usar `google_generative_ai`, porque ese paquete esta
/// deprecado y Google ya no lo actualiza.
///
/// La API key se lee de `.env` (nunca del codigo ni del repo). Ojo: un `.env`
/// viaja dentro del APK y es extraible, asi que la proteccion real es
/// restringir la key en Google Cloud (API restrictions: Generative Language
/// API; Application restrictions: Android, package proyecto.app + SHA-1).
class IaVocacionalService {
  /// Modelos en orden de preferencia. Se prueban en cascada: si uno ya no esta
  /// disponible para cuentas nuevas (404) o viene saturado (503), se pasa al
  /// siguiente. El alias "latest" va primero porque no queda obsoleto.
  static const List<String> _modelos = [
    'gemini-flash-latest',
    'gemini-3.7-flash',
    'gemini-3.8-flash',
  ];

  static const String _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Instruccion de sistema para el test de preguntas.
  static const String _instruccionPreguntas = '''
Sos un orientador vocacional para estudiantes del conurbano bonaerense
(San Miguel, Jose C. Paz y Malvinas Argentinas). Hablas en español
rioplatense, con tono cercano y claro. No inventas datos.

Debes responder SIEMPRE en español estándar, incluyendo tildes y la letra ñ
(p. ej. "año", "compañeros", "más"), nunca en forma abreviada o sin acentos.''';

  /// Instruccion de sistema para el perfil. El grounding va aca (y no solo en
  /// el prompt del usuario) porque el systemInstruction pesa mas y aplica a
  /// toda la respuesta.
  static const String _instruccionPerfil = '''
Sos un orientador vocacional para estudiantes del conurbano bonaerense
(San Miguel, Jose C. Paz y Malvinas Argentinas). Hablas en español
rioplatense, con tono cercano y claro.

Debes responder SIEMPRE en español estándar, incluyendo tildes y la letra ñ
(p. ej. "año", "compañeros", "más"), nunca en forma abreviada o sin acentos.

REGLA CRITICA, POR ENCIMA DE CUALQUIER OTRA: la unica fuente valida de
carreras, instituciones y sedes es la lista "OFERTAS DISPONIBLES" que te
entrega el usuario. Tenes PROHIBIDO inventar, suponer, completar o mencionar
cualquier carrera, institucion, sede, sigla o localidad que no figure
TEXTUALMENTE en esa lista, aunque la conozcas, exista de verdad o te parezca
obvia. Si la lista esta vacia, no recomiendas ninguna carrera.''';

  /// Claves de area que entiende la app. Tienen que coincidir con el enum
  /// AreaInteres (test_vocacional_model.dart) y con el scoring de TestService.
  static const List<String> _areas = [
    'tecnologia',
    'salud',
    'educacion',
    'creativa',
  ];

  /// Base comun de todas las llamadas: los modelos 3.x gastan tokens
  /// "pensando" y con un tope chico la respuesta vuelve vacia (finishReason
  /// MAX_TOKENS). Para el test no hace falta cadena de razonamiento: apagarlo
  /// baja la latencia.
  static const Map<String, dynamic> _configBase = {
    'maxOutputTokens': 2048,
    'thinkingConfig': {'thinkingBudget': 0},
  };

  /// Config de las preguntas: ademas exige JSON valido con forma fija. El
  /// `responseSchema` lo garantiza a nivel API: no depende de que el modelo
  /// "quiera" respetar el formato pedido en el prompt.
  static const Map<String, dynamic> _configPreguntas = {
    ..._configBase,
    'temperature': 0.9,
    'responseMimeType': 'application/json',
    'responseSchema': {
      'type': 'ARRAY',
      'items': {
        'type': 'OBJECT',
        'properties': {
          'texto': {'type': 'STRING'},
          'opciones': {
            'type': 'ARRAY',
            'items': {
              'type': 'OBJECT',
              'properties': {
                'texto': {'type': 'STRING'},
                // El enum evita areas inventadas; que las 4 sean distintas
                // dentro de cada pregunta se valida despues, porque el schema
                // no puede expresar esa regla.
                'area': {'type': 'STRING', 'enum': _areas},
              },
              'required': ['texto', 'area'],
            },
          },
        },
        'required': ['texto', 'opciones'],
      },
    },
  };

  /// Config del perfil: salida estructurada, con la carrera restringida por
  /// `enum` a las ofertas reales de la app. Asi la invencion queda
  /// imposibilitada a nivel API, no depende de que el modelo "obedezca" el
  /// prompt. `ofertas` son los textos exactos que ya se le pasan en la lista.
  Map<String, dynamic> _configPerfil(List<String> ofertas) {
    const base = {
      ..._configBase,
      'temperature': 0.6,
      'responseMimeType': 'application/json',
    };

    // Sin ofertas no se pide lista de carreras: un enum vacio es invalido.
    if (ofertas.isEmpty) {
      return {
        ...base,
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'perfil': {'type': 'STRING'},
          },
          'required': ['perfil'],
        },
      };
    }

    final maximo = ofertas.length < 3 ? ofertas.length : 3;
    return {
      ...base,
      'responseSchema': {
        'type': 'OBJECT',
        'properties': {
          'perfil': {'type': 'STRING'},
          'carreras': {
            'type': 'ARRAY',
            'maxItems': maximo,
            'items': {
              'type': 'OBJECT',
              'properties': {
                // enum: solo carreras que existen en la base.
                'opcion': {'type': 'STRING', 'enum': ofertas},
                'motivo': {'type': 'STRING'},
              },
              'required': ['opcion', 'motivo'],
            },
          },
        },
        'required': ['perfil', 'carreras'],
      },
    };
  }

  static const String _promptPreguntas = '''
Genera un test vocacional expres: EXACTAMENTE 5 preguntas situacionales o de
preferencias, con 4 opciones cada una.

Cada opcion tiene que corresponder a UNA de estas cuatro areas, y dentro de
cada pregunta las cuatro areas deben aparecer UNA sola vez:
- "tecnologia": resolver problemas logicos, datos, sistemas, informatica.
- "salud": cuidar personas, ciencias de la salud, bienestar.
- "educacion": ensenar, explicar, liderar, organizar.
- "creativa": disenar, expresarse, crear contenidos, arte.

Las 5 preguntas deben ser distintas entre si (no reformulaciones de la misma).
Lenguaje simple y rioplatense, sin comillas raras.''';

  /// Genera las 5 preguntas del test como JSON crudo (ver `_configPreguntas`
  /// para la forma exacta). Devuelve `null` si no hay API key configurada.
  /// Lanza [Exception] si la API responde con error.
  Future<String?> generarPreguntasTest() async {
    final key = _apiKey();
    if (key == null) return null;
    return _pedirAGemini(
      key,
      _promptPreguntas,
      _configPreguntas,
      instruccionSistema: _instruccionPreguntas,
    );
  }

  /// Genera el perfil vocacional a partir de las respuestas. Devuelve `null`
  /// si no hay API key configurada o si la respuesta no se puede interpretar.
  Future<String?> generarPerfil({
    required List<String> respuestas,
    required String areaPrincipal,
    required int aciertosArea,
    required int totalRespuestas,
    List<String> ofertasLocales = const [],
  }) async {
    final key = _apiKey();
    if (key == null) return null;

    final crudo = await _pedirAGemini(
      key,
      _construirPromptPerfil(
        respuestas: respuestas,
        areaPrincipal: areaPrincipal,
        aciertosArea: aciertosArea,
        totalRespuestas: totalRespuestas,
        ofertasLocales: ofertasLocales,
      ),
      _configPerfil(ofertasLocales),
      instruccionSistema: _instruccionPerfil,
    );
    if (crudo == null) return null;
    return _componerPerfil(crudo, ofertasLocales);
  }

  String? _apiKey() {
    final key = dotenv.maybeGet('GEMINI_API_KEY');
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  /// POST a `generateContent` con cascada de modelos y reintentos.
  ///
  /// Devuelve el texto de la respuesta (en el modo JSON, el JSON crudo).
  Future<String?> _pedirAGemini(
    String key,
    String prompt,
    Map<String, dynamic> generationConfig, {
    required String instruccionSistema,
  }) async {
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': instruccionSistema},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': generationConfig,
    });

    Object? ultimoError;

    for (final modelo in _modelos) {
      for (var intento = 0; intento < 2; intento++) {
        http.Response res;
        try {
          res = await http
              .post(
                Uri.parse('$_base/$modelo:generateContent'),
                headers: {
                  'Content-Type': 'application/json',
                  // Header y no ?key=: evita que la clave quede en URLs y logs.
                  'x-goog-api-key': key,
                },
                body: body,
              )
              .timeout(const Duration(seconds: 25));
        } catch (e) {
          ultimoError = e; // Red o timeout: vale reintentar.
          if (intento == 0) {
            await Future.delayed(const Duration(milliseconds: 800));
            continue;
          }
          break; // Se agoto este modelo, se prueba el siguiente.
        }

        if (res.statusCode == 200) return _extraerTexto(res.bodyBytes);

        if (res.statusCode == 404) {
          // El modelo ya no existe para esta cuenta: no insistir con el.
          ultimoError = Exception('$modelo no esta disponible (HTTP 404)');
          break;
        }

        if (res.statusCode == 429 || res.statusCode == 503) {
          ultimoError = Exception('Gemini saturado (HTTP ${res.statusCode})');
          if (intento == 0) {
            await Future.delayed(const Duration(milliseconds: 800));
            continue;
          }
          break;
        }

        // Cualquier otro codigo (400/401/403) es un problema real del request
        // o de la key: reintentar no ayuda, se reporta tal cual.
        throw Exception(
          'Gemini respondio HTTP ${res.statusCode}: '
          '${utf8.decode(res.bodyBytes)}',
        );
      }
    }

    throw ultimoError ?? Exception('No se pudo obtener respuesta de Gemini');
  }

  /// Prompt del perfil con grounding estricto: la IA solo puede recomendar
  /// carreras que esten textualmente en la lista de ofertas.
  String _construirPromptPerfil({
    required List<String> respuestas,
    required String areaPrincipal,
    required int aciertosArea,
    required int totalRespuestas,
    required List<String> ofertasLocales,
  }) {
    final resumen = StringBuffer()
      ..writeln('Respuestas del test vocacional expres:');
    for (final r in respuestas) {
      resumen.writeln('- $r');
    }

    // La seccion se imprime SIEMPRE, aunque este vacia: si no aparece, el
    // modelo se siente libre de recomendar lo que se le ocurra.
    final inventario = StringBuffer();
    if (ofertasLocales.isEmpty) {
      inventario.writeln(
          'OFERTAS DISPONIBLES: no hay ninguna carrera cargada para esta area.');
    } else {
      inventario.writeln('OFERTAS DISPONIBLES (unica fuente permitida):');
      for (var i = 0; i < ofertasLocales.length; i++) {
        inventario.writeln('${i + 1}. ${ofertasLocales[i]}');
      }
    }

    final maximo = ofertasLocales.length < 3 ? ofertasLocales.length : 3;

    return '''
$resumen
Area de interes detectada por el test: $areaPrincipal
($aciertosArea de $totalRespuestas respuestas).

$inventario

REGLAS OBLIGATORIAS:
- Elegi las carreras UNICAMENTE de OFERTAS DISPONIBLES: no hay otra fuente.
- En "opcion" copia el texto EXACTO de una de las ofertas de la lista, sin
  cambiarle ni una palabra ni el orden de sus datos.
- Prohibido inventar carreras, instituciones, sedes, siglas o barrios.
- Las recomendaciones tienen que ser afines al area detectada.
- Si hay menos de 3 ofertas utiles, devolve solo esas. Si la lista esta
  vacia, devolve "carreras" como lista vacia.

Devolve:
1) "perfil": un parrafo de 3 a 5 oraciones sobre sus intereses, sus
   fortalezas y el tipo de trabajo que le puede resultar mas satisfactorio.
   No menciones carreras ni instituciones aca.
2) "carreras": hasta $maximo elementos, cada uno con "opcion" (copiada tal
   cual de la lista) y "motivo" (por que encaja con su perfil, una oracion).

Maximo 220 palabras en total.
''';
  }

  /// Convierte el JSON validado del perfil en el texto plano que ya sabe
  /// mostrar la pantalla de resultados.
  String? _componerPerfil(String crudo, List<String> ofertas) {
    final dynamic json = jsonDecode(crudo);
    if (json is! Map) return null;

    final buffer = StringBuffer();
    final perfil = json['perfil']?.toString().trim() ?? '';
    if (perfil.isNotEmpty) buffer.writeln(perfil);

    // Doble control: aunque el enum ya lo impide, se descarta cualquier
    // opcion que no sea una oferta real de la lista.
    final permitidas = ofertas.toSet();
    final carreras = json['carreras'];
    final validas = <Map>[];
    if (carreras is List) {
      for (final c in carreras) {
        if (c is! Map) continue;
        final opcion = c['opcion']?.toString().trim() ?? '';
        if (opcion.isEmpty || !permitidas.contains(opcion)) continue;
        validas.add(c);
      }
    }

    if (validas.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Carreras recomendadas:');
      for (final c in validas) {
        final opcion = c['opcion'].toString().trim();
        final motivo = c['motivo']?.toString().trim() ?? '';
        buffer.writeln(motivo.isEmpty ? '$opcion.' : '$opcion: $motivo.');
      }
    } else if (ofertas.isEmpty) {
      buffer
        ..writeln()
        ..writeln('Todavía no hay carreras cargadas para esta área.');
    }

    final texto = buffer.toString().trim();
    return texto.isEmpty ? null : texto;
  }

  /// Extrae `candidates[0].content.parts[0].text`.
  ///
  /// Se decodifica utf8 a mano porque `res.body` cae a latin1 cuando la
  /// respuesta no declara charset, y eso rompe tildes y enies.
  String? _extraerTexto(List<int> bodyBytes) {
    final dynamic json = jsonDecode(utf8.decode(bodyBytes));
    if (json is! Map) return null;

    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;

    final content = candidates.first['content'];
    if (content is! Map) return null;

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;

    final primero = parts.first;
    if (primero is! Map) return null;

    final texto = primero['text']?.toString().trim();
    return (texto == null || texto.isEmpty) ? null : texto;
  }
}
