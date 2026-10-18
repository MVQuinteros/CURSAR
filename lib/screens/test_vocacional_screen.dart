import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/test_vocacional_model.dart';
import '../services/ia_vocacional_service.dart';
import '../services/test_service.dart';
import '../theme/app_theme.dart';

class TestVocacionalScreen extends StatefulWidget {
  const TestVocacionalScreen({super.key});

  @override
  State<TestVocacionalScreen> createState() => _TestVocacionalScreenState();
}

class _OpcionTest {
  final String texto;

  /// Area a la que suma esta opcion. La decide la IA (o el respaldo), no la
  /// posicion en la lista.
  final AreaInteres area;

  const _OpcionTest(this.texto, this.area);

  /// Slot 0..3 que espera TestService.calcularResultado / obtenerConteoAreas.
  /// Coincide con el orden del enum AreaInteres (tecnologia, salud, educacion,
  /// creativa). Si alguien reordena ese enum, el puntaje se rompe en silencio.
  int get slot => area.index;

  IconData get icono => area.icono;
}

class _PreguntaTest {
  final String texto;
  final List<_OpcionTest> opciones;

  const _PreguntaTest(this.texto, this.opciones);
}

class _TestVocacionalScreenState extends State<TestVocacionalScreen> {
  static const Color _azulGradienteInicio = Color(0xFF1B74E4);
  static const Color _azulGradienteFin = Color(0xFF58B2FF);

  final TestService _testService = TestService();
  final IaVocacionalService _iaService = IaVocacionalService();

  /// Preguntas de respaldo: se usan si Gemini falla, tarda demasiado o
  /// devuelve un JSON que no pasa la validacion. El orden de las opciones ya
  /// es tecnologia, salud, educacion, creativa (una por area).
  static const List<_PreguntaTest> _preguntasRespaldo = [
    _PreguntaTest(
      '¿Qué actividad disfrutás más hacer en tu tiempo libre?',
      [
        _OpcionTest(
          'Resolver problemas lógicos o usar la tecnología',
          AreaInteres.tecnologia,
        ),
        _OpcionTest(
          'Ayudar a otras personas o cuidar su bienestar',
          AreaInteres.salud,
        ),
        _OpcionTest(
          'Enseñar, explicar o liderar equipos',
          AreaInteres.educacion,
        ),
        _OpcionTest(
          'Crear contenidos, diseñar o expresarme',
          AreaInteres.creativa,
        ),
      ],
    ),
    _PreguntaTest(
      '¿Qué materia preferías en la escuela?',
      [
        _OpcionTest('Matemática o computación', AreaInteres.tecnologia),
        _OpcionTest('Biología o salud', AreaInteres.salud),
        _OpcionTest('Historia o ciudadanía', AreaInteres.educacion),
        _OpcionTest('Arte o literatura', AreaInteres.creativa),
      ],
    ),
    _PreguntaTest(
      '¿Cómo te imaginás tu trabajo ideal?',
      [
        _OpcionTest('Resolviendo problemas técnicos', AreaInteres.tecnologia),
        _OpcionTest('Ayudando a las personas', AreaInteres.salud),
        _OpcionTest('Dirigiendo un equipo', AreaInteres.educacion),
        _OpcionTest('Creando algo original', AreaInteres.creativa),
      ],
    ),
    _PreguntaTest(
      '¿Qué tarea te resulta más natural?',
      [
        _OpcionTest('Analizar datos o armar sistemas', AreaInteres.tecnologia),
        _OpcionTest('Escuchar y contener a otros', AreaInteres.salud),
        _OpcionTest('Explicar y organizar', AreaInteres.educacion),
        _OpcionTest('Dibujar, escribir o filmar', AreaInteres.creativa),
      ],
    ),
    _PreguntaTest(
      '¿En qué situación rendís mejor?',
      [
        _OpcionTest('Con un desafío lógico', AreaInteres.tecnologia),
        _OpcionTest('Ayudando a alguien en apuros', AreaInteres.salud),
        _OpcionTest('Coordinando un grupo', AreaInteres.educacion),
        _OpcionTest('Con un proyecto creativo', AreaInteres.creativa),
      ],
    ),
  ];

  int _indiceActual = 0;
  bool _guardando = false;

  /// Mientras es true se muestra "Generando tu test personalizado...".
  bool _generandoTest = true;

  List<_PreguntaTest> _preguntas = [];
  List<int?> _selecciones = [];

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  /// Pide las 5 preguntas a Gemini y, si algo falla, usa el respaldo.
  ///
  /// Nunca deja la pantalla sin preguntas: el test siempre se puede hacer.
  Future<void> _cargarPreguntas() async {
    List<_PreguntaTest>? generadas;
    try {
      final crudo = await _iaService.generarPreguntasTest();
      if (crudo != null) generadas = _parsearPreguntas(crudo);
    } catch (e) {
      debugPrint('[TEST IA] No se pudieron generar las preguntas: $e');
    }

    final preguntas = generadas ?? _preguntasRespaldo;
    if (!mounted) return;
    setState(() {
      _preguntas = preguntas;
      _selecciones = List<int?>.filled(preguntas.length, null);
      _indiceActual = 0;
      _generandoTest = false;
    });
  }

  /// Convierte la clave de area que devuelve la IA en el enum de la app.
  AreaInteres? _areaDesdeClave(String? clave) {
    switch (clave?.trim().toLowerCase()) {
      case 'tecnologia':
        return AreaInteres.tecnologia;
      case 'salud':
        return AreaInteres.salud;
      case 'educacion':
        return AreaInteres.educacion;
      case 'creativa':
        return AreaInteres.creativa;
      default:
        return null;
    }
  }

  /// Parsea y valida el JSON de Gemini. Devuelve `null` si no cumple el
  /// contrato (5 preguntas, 4 opciones, las 4 areas distintas en cada una).
  List<_PreguntaTest>? _parsearPreguntas(String crudo) {
    try {
      final dynamic datos = jsonDecode(crudo);
      if (datos is! List || datos.length != 5) return null;

      final preguntas = <_PreguntaTest>[];
      for (final item in datos) {
        if (item is! Map) return null;
        final texto = item['texto']?.toString().trim() ?? '';
        final crudas = item['opciones'];
        if (texto.isEmpty || crudas is! List || crudas.length != 4) {
          return null;
        }

        final opciones = <_OpcionTest>[];
        final areasVistas = <AreaInteres>{};
        for (final o in crudas) {
          if (o is! Map) return null;
          final textoOpcion = o['texto']?.toString().trim() ?? '';
          final area = _areaDesdeClave(o['area']?.toString());
          // Texto vacio, area desconocida o area repetida: JSON invalido.
          if (textoOpcion.isEmpty || area == null || !areasVistas.add(area)) {
            return null;
          }
          opciones.add(_OpcionTest(textoOpcion, area));
        }
        preguntas.add(_PreguntaTest(texto, opciones));
      }
      return preguntas;
    } catch (e) {
      debugPrint('[TEST IA] JSON de preguntas invalido: $e');
      return null;
    }
  }

  void _seleccionarOpcion(int slot) {
    setState(() {
      _selecciones[_indiceActual] = slot;
    });
  }

  void _irAtras() {
    if (_indiceActual > 0) {
      setState(() {
        _indiceActual--;
      });
    }
  }

  void _irASiguiente() {
    if (_selecciones[_indiceActual] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccioná una opción antes de continuar'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_indiceActual < _preguntas.length - 1) {
      setState(() {
        _indiceActual++;
      });
    } else {
      _finalizarTest();
    }
  }

  /// Arma los pares "pregunta -> opcion elegida" para mandarle a la IA.
  ///
  /// `_selecciones` guarda el slot del area (0..3), no la posicion de la
  /// opcion, asi que hay que buscar cual opcion corresponde a ese slot.
  List<String> _respuestasTexto() {
    final lista = <String>[];
    for (var i = 0; i < _preguntas.length; i++) {
      final slot = _selecciones[i];
      if (slot == null) continue;
      final opcion = _preguntas[i].opciones.firstWhere(
            (o) => o.slot == slot,
            orElse: () => _preguntas[i].opciones.first,
          );
      lista.add('${_preguntas[i].texto} -> ${opcion.texto}');
    }
    return lista;
  }

  Future<void> _finalizarTest() async {
    setState(() => _guardando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debés iniciar sesión para guardar el resultado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final areaInteres = _testService.calcularResultado(_selecciones);
      final ofertas = await _testService.obtenerOfertasPorArea(areaInteres);
      final ofertasIds = ofertas.map((o) => o.ofertaId).toList();

      await _testService.guardarResultadoCompleto(
        userUid: user.uid,
        areaInteres: areaInteres,
        ofertasRecomendadas: ofertasIds,
      );

      // Ofertas reales del area para "anclar" la respuesta de la IA: se le
      // pasan formateadas (con el nombre real de la institucion y su ciudad)
      // para que recomiende cosas que existen en la app y no invente.
      final ofertasLocales = await _testService.formatearParaIA(ofertas);

      // La IA va aparte a proposito: si falla, el test igual llega a
      // resultados, solo que sin el perfil personalizado.
      String? perfilIa;
      try {
        perfilIa = await _iaService.generarPerfil(
          respuestas: _respuestasTexto(),
          areaPrincipal: areaInteres.nombre,
          aciertosArea:
              _testService.obtenerConteoAreas(_selecciones)[areaInteres] ?? 0,
          totalRespuestas: _selecciones.where((s) => s != null).length,
          ofertasLocales: ofertasLocales,
        );
      } catch (e) {
        debugPrint('[TEST IA] No se pudo generar el perfil: $e');
      }

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/test-resultados',
          arguments: {
            'areaInteres': areaInteres,
            'selecciones': _selecciones,
            'perfilIa': perfilIa,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  void _navegar(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/favoritos');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras se espera el test de la IA, se reemplaza toda la pantalla por
    // el indicador.
    if (_generandoTest) {
      return _buildPantallaCarga(
        'Generando tu test personalizado...',
        'Estamos armando 5 preguntas para vos.',
      );
    }

    // Mientras se guarda y se le pide el perfil a la IA, se reemplaza toda la
    // pantalla por el indicador: evita que se toquen opciones a mitad de camino.
    if (_guardando) {
      return _buildPantallaCarga(
        'Analizando tu perfil...',
        'Estamos generando una recomendación personalizada para vos.',
      );
    }

    final pregunta = _preguntas[_indiceActual];
    final seleccion = _selecciones[_indiceActual];
    final esUltima = _indiceActual == _preguntas.length - 1;
    final esPrimera = _indiceActual == 0;
    final progreso = (_indiceActual + 1) / _preguntas.length;

    return Scaffold(
      backgroundColor: context.colors.bgMain,
      body: Column(
        children: [
          _buildEncabezado(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIndicadorProgreso(progreso),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _buildTarjetaPregunta(pregunta, seleccion),
                            ),
                            const SizedBox(height: 20),
                            if (!esPrimera) ...[
                              _buildBotonAnterior(),
                              const SizedBox(height: 12),
                            ],
                            _buildBotonSiguiente(esUltima),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: _navegar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  /// Pantalla completa de carga: se usa mientras Gemini arma el test o el
  /// perfil. Sin barra de navegacion a proposito: no conviene que el usuario
  /// se vaya a mitad del proceso.
  Widget _buildPantallaCarga(String titulo, String subtitulo) {
    return Scaffold(
      backgroundColor: context.colors.bgMain,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            builder: (context, valor, child) => Opacity(
              opacity: valor,
              child: Transform.scale(scale: 0.9 + 0.1 * valor, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(strokeWidth: 5),
                ),
                const SizedBox(height: 28),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEncabezado() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 28,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_azulGradienteInicio, _azulGradienteFin],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Spacer(),
                  const _LogoTest(),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Test vocacional exprés',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Respondé 5 preguntas y descubrí tus áreas de interés',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadorProgreso(double progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pregunta ${_indiceActual + 1} de ${_preguntas.length}',
          style: TextStyle(color: context.colors.textPrimary, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 8,
            backgroundColor: context.colors.borderSubtle,
            color: context.colors.accentPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaPregunta(_PreguntaTest pregunta, int? seleccion) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            pregunta.texto,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final opcion in pregunta.opciones) ...[
            _buildOpcion(
              opcion,
              seleccion == opcion.slot,
              () => _seleccionarOpcion(opcion.slot),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOpcion(
    _OpcionTest opcion,
    bool seleccionada,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionada
                ? context.colors.accentPrimary
                : context.colors.borderSubtle,
            width: seleccionada ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(opcion.icono, color: context.colors.accentPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                opcion.texto,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: seleccionada ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              seleccionada
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: seleccionada
                  ? context.colors.accentPrimary
                  : context.colors.iconNormal,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonAnterior() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _guardando ? null : _irAtras,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colors.accentPrimary,
          side: BorderSide(color: context.colors.accentPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Anterior'),
      ),
    );
  }

  Widget _buildBotonSiguiente(bool esUltima) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _guardando ? null : _irASiguiente,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.accentPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: context.colors.borderSubtle,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: _guardando
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(esUltima ? 'Ver resultados' : 'Siguiente'),
      ),
    );
  }
}

class _LogoTest extends StatelessWidget {
  const _LogoTest();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, color: Colors.white, size: 46),
        Icon(Icons.school, color: Color(0xFF1877F2), size: 18),
      ],
    );
  }
}