import 'package:flutter/material.dart';
import '../models/test_vocacional_model.dart';
import '../models/oferta_model.dart';
import '../services/test_service.dart';
import '../theme/app_theme.dart';

class TestResultadosScreen extends StatefulWidget {
  const TestResultadosScreen({super.key});

  @override
  State<TestResultadosScreen> createState() => _TestResultadosScreenState();
}

class _TestResultadosScreenState extends State<TestResultadosScreen> {
  final TestService _testService = TestService();

  AreaInteres? _areaInteres;
  List<int?> _selecciones = [];
  Map<AreaInteres, int> _conteoAreas = {};
  List<OfertaModel> _ofertasRecomendadas = [];
  bool _cargando = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_areaInteres == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _areaInteres = args['areaInteres'] as AreaInteres;
        _selecciones = args['selecciones'] as List<int?>;
      }
      _cargarResultados();
    }
  }

  Future<void> _cargarResultados() async {
    if (_areaInteres == null) return;

    try {
      _conteoAreas = _testService.obtenerConteoAreas(_selecciones);
      _ofertasRecomendadas = await _testService.obtenerOfertasPorArea(_areaInteres!);
    } catch (e) {
      debugPrint('Error al cargar resultados: $e');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _navegar(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/test');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: context.colors.bgMain,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final area = _areaInteres ?? AreaInteres.tecnologia;
    final totalRespuestas = _selecciones.where((s) => s != null).length;
    final respuestasArea = _conteoAreas[area] ?? 0;
    final porcentaje = totalRespuestas > 0
        ? ((respuestasArea / totalRespuestas) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: context.colors.bgMain,
      body: Column(
        children: [
          _buildEncabezado(area),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTarjetaResultado(area, porcentaje),
                  const SizedBox(height: 24),
                  _buildDistribucion(),
                  const SizedBox(height: 24),
                  _buildOfertasRecomendadas(),
                  const SizedBox(height: 24),
                  _buildBotonesAccion(),
                ],
              ),
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

  Widget _buildEncabezado(AreaInteres area) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 28,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [area.color, area.color.withValues(alpha: 0.7)],
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
                  const Text(
                    'Resultado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${area.imagen} ¡Test completado!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Descubrimos tu área de interés',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaResultado(AreaInteres area, int porcentaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: area.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              area.icono,
              size: 50,
              color: area.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tu área es',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            area.nombre,
            style: TextStyle(
              color: area.color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: area.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$porcentaje% de tus respuestas',
              style: TextStyle(
                color: area.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            area.descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistribucion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución de respuestas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: AreaInteres.values.map((area) {
              final conteo = _conteoAreas[area] ?? 0;
              final total = _selecciones.where((s) => s != null).length;
              final porcentaje = total > 0 ? (conteo / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(area.icono, size: 18, color: area.color),
                            const SizedBox(width: 8),
                            Text(
                              area.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$conteo',
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 8,
                        backgroundColor: context.colors.borderSubtle,
                        color: area.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOfertasRecomendadas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ofertas recomendadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_ofertasRecomendadas.isNotEmpty)
              Text(
                '${_ofertasRecomendadas.length} opciones',
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_ofertasRecomendadas.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off,
                    size: 48, color: context.colors.iconNormal),
                const SizedBox(height: 12),
                Text(
                  'No se encontraron ofertas para esta área',
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Intentá con otro test o explorá todas las ofertas',
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ..._ofertasRecomendadas.map((oferta) => _buildTarjetaOferta(oferta)),
      ],
    );
  }

  Widget _buildTarjetaOferta(OfertaModel oferta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oferta.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${oferta.institucionUid.toUpperCase()} · ${oferta.nivel}',
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.accentPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${oferta.duracionAnios} ${oferta.duracionAnios == 1 ? 'año' : 'años'}',
                  style: TextStyle(
                    color: context.colors.accentPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            oferta.descripcion,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChipInfo(Icons.school, oferta.modalidad),
              _buildChipInfo(Icons.work, oferta.salidaLaboral.split(',')[0].trim()),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.accentPrimary,
                side: BorderSide(color: context.colors.accentPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ver detalles'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.colors.borderSubtle.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accentPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Explorar todas las ofertas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/test');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.accentPrimary,
              side: BorderSide(color: context.colors.accentPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Volver a hacer el test',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text(
            'Volver al inicio',
            style: TextStyle(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}