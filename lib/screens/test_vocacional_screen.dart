import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/test_service.dart';

class TestVocacionalScreen extends StatefulWidget {
  const TestVocacionalScreen({super.key});

  @override
  State<TestVocacionalScreen> createState() => _TestVocacionalScreenState();
}

class _OpcionTest {
  final String texto;
  final IconData icono;

  const _OpcionTest(this.texto, this.icono);
}

class _PreguntaTest {
  final String texto;
  final List<_OpcionTest> opciones;

  const _PreguntaTest(this.texto, this.opciones);
}

class _TestVocacionalScreenState extends State<TestVocacionalScreen> {
  static const Color _azulPrimario = Color(0xFF1877F2);
  static const Color _azulGradienteInicio = Color(0xFF1B74E4);
  static const Color _azulGradienteFin = Color(0xFF58B2FF);
  static const Color _grisOscuro = Color(0xFF424242);
  static const Color _grisClaro = Color(0xFFE0E0E0);
  static const Color _grisMedio = Color(0xFF9E9E9E);
  static const Color _fondoPantalla = Color(0xFFF8F9FA);

  final TestService _testService = TestService();

  final List<_PreguntaTest> _preguntas = [
    _PreguntaTest(
      '¿Qué actividad disfrutás más hacer en tu tiempo libre?',
      const [
        _OpcionTest(
          'Resolver problemas lógicos o usar la tecnología',
          Icons.computer,
        ),
        _OpcionTest(
          'Ayudar a otras personas o cuidar su bienestar',
          Icons.favorite,
        ),
        _OpcionTest(
          'Enseñar, explicar o liderar equipos',
          Icons.people,
        ),
        _OpcionTest(
          'Crear contenidos, diseñar o expresarme',
          Icons.palette,
        ),
      ],
    ),
    _PreguntaTest(
      '¿Qué materia preferías en la escuela?',
      const [
        _OpcionTest('Matemática o computación', Icons.calculate),
        _OpcionTest('Biología o salud', Icons.biotech),
        _OpcionTest('Historia o ciudadanía', Icons.history_edu),
        _OpcionTest('Arte o literatura', Icons.palette),
      ],
    ),
    _PreguntaTest(
      '¿Cómo te imaginás tu trabajo ideal?',
      const [
        _OpcionTest('Resolviendo problemas técnicos', Icons.terminal),
        _OpcionTest('Ayudando a las personas', Icons.volunteer_activism),
        _OpcionTest('Dirigiendo un equipo', Icons.groups),
        _OpcionTest('Creando algo original', Icons.brush),
      ],
    ),
    _PreguntaTest(
      '¿Qué tarea te resulta más natural?',
      const [
        _OpcionTest('Analizar datos o armar sistemas', Icons.analytics),
        _OpcionTest('Escuchar y contener a otros', Icons.favorite),
        _OpcionTest('Explicar y organizar', Icons.school),
        _OpcionTest('Dibujar, escribir o filmar', Icons.edit),
      ],
    ),
    _PreguntaTest(
      '¿En qué situación rendís mejor?',
      const [
        _OpcionTest('Con un desafío lógico', Icons.extension),
        _OpcionTest('Ayudando a alguien en apuros', Icons.volunteer_activism),
        _OpcionTest('Coordinando un grupo', Icons.groups),
        _OpcionTest('Con un proyecto creativo', Icons.design_services),
      ],
    ),
  ];

  int _indiceActual = 0;
  bool _guardando = false;

  late final List<int?> _selecciones =
      List<int?>.filled(_preguntas.length, null);

  void _seleccionarOpcion(int indexOpcion) {
    setState(() {
      _selecciones[_indiceActual] = indexOpcion;
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

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/test-resultados',
          arguments: {
            'areaInteres': areaInteres,
            'selecciones': _selecciones,
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
    if (index == 0 || index == 2) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = _preguntas[_indiceActual];
    final seleccion = _selecciones[_indiceActual];
    final esUltima = _indiceActual == _preguntas.length - 1;
    final esPrimera = _indiceActual == 0;
    final progreso = (_indiceActual + 1) / _preguntas.length;

    return Scaffold(
      backgroundColor: _fondoPantalla,
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
        selectedItemColor: _azulPrimario,
        unselectedItemColor: _grisMedio,
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
          style: const TextStyle(color: _grisOscuro, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 8,
            backgroundColor: _grisClaro,
            color: _azulPrimario,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            style: const TextStyle(
              color: Color(0xFF212121),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          for (var i = 0; i < pregunta.opciones.length; i++) ...[
            _buildOpcion(
              pregunta.opciones[i],
              seleccion == i,
              () => _seleccionarOpcion(i),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionada ? _azulPrimario : _grisClaro,
            width: seleccionada ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(opcion.icono, color: _azulPrimario, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                opcion.texto,
                style: TextStyle(
                  color: _grisOscuro,
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
              color: seleccionada ? _azulPrimario : _grisMedio,
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
          foregroundColor: _azulPrimario,
          side: const BorderSide(color: _azulPrimario, width: 1.5),
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
          backgroundColor: _azulPrimario,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _grisMedio,
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
