import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reporte_model.dart';
import '../services/soporte_service.dart';
import '../theme/app_theme.dart';

class AyudaSoporteScreen extends StatefulWidget {
  const AyudaSoporteScreen({super.key});

  @override
  State<AyudaSoporteScreen> createState() => _AyudaSoporteScreenState();
}

class _AyudaSoporteScreenState extends State<AyudaSoporteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mensajeController = TextEditingController();
  final _emailController = TextEditingController();

  String _tipo = 'Problema';
  bool _enviando = false;

  static const List<String> _tiposReporte = ['Problema', 'Consulta', 'Sugerencia'];
  static const List<(String, String)> _faq = [
    (
      '¿Cómo guardo una carrera en favoritos?',
      'Andá a la ficha o al listado de una carrera y tocá el ícono de corazón '
      'para guardarla. Después podés verlas todas desde la pestaña Favoritos '
      '(el corazón de la barra inferior). Para quitarla, tocá el corazón otra vez.',
    ),
    (
      '¿Cómo cambio mi ubicación de búsqueda?',
      'Entrá a Mi perfil y tocá la opción "Radio de búsqueda". Ahí elegís la '
      'distancia en kilómetros (5, 10, 20, 50 o 100 km) que querés que abarque '
      'tu búsqueda. También podés editar tu localidad desde "Editar perfil".',
    ),
    (
      '¿Qué es el test vocacional?',
      'Es un test exprés de 5 preguntas, disponible en la pestaña Test, que '
      'analiza tus gustos y te muestra tus áreas de interés con un porcentaje. '
      'Al final te recomendamos carreras e instituciones que se ajustan a tu perfil.',
    ),
    (
      '¿Cómo contacto con una institución?',
      'En la ficha de cada institución vas a encontrar su teléfono, email, '
      'dirección y un botón para verla en el mapa. Si todavía no aparece algún '
      'dato, escribinos desde el formulario más abajo y lo gestionamos.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;

    setState(() => _enviando = true);
    try {
      await SoporteService().enviarReporte(
        ReporteModel(
          uid: user?.uid,
          email: _emailController.text.trim(),
          tipo: _tipo,
          mensaje: _mensajeController.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gracias por tu reporte, lo recibimos correctamente')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo enviar el reporte. Intentá de nuevo.')),
      );
    }
  }

  InputDecoration _decoration(String hint, IconData icono) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14),
      prefixIcon: Icon(icono, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgMain,
      appBar: AppBar(
        title: const Text('Ayuda y soporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Preguntas frecuentes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ..._faq.map(
              (item) {
                final pregunta = item.$1;
                final respuesta = item.$2;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.colors.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                    childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Text(
                      pregunta,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    children: [
                      Text(
                        respuesta,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              '¿Encontraste un problema?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Contanos qué pasó y lo vamos a revisar.',
              style: TextStyle(
                  fontSize: 12, color: context.colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _tipo,
                    decoration: _decoration('Tipo de reporte', Icons.flag_outlined),
                    items: _tiposReporte
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _tipo = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration('Tu email', Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresá un email de contacto';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _mensajeController,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _decoration(
                      'Describí el problema...',
                      Icons.description_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 10) {
                        return 'Contanos un poco más (mínimo 10 caracteres)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _enviando ? null : _enviar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.accentPrimary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          context.colors.accentPrimary.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Enviar reporte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}