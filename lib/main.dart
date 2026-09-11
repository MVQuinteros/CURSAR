import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';
import 'home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/configuracion_screen.dart';
import 'screens/ayuda_soporte_screen.dart';
import 'screens/test_vocacional_screen.dart';
import 'screens/test_resultados_screen.dart';
import 'screens/map_screen.dart';
import 'screens/institucion_detail_screen.dart';
import 'seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  final ofertaDoc = await FirebaseFirestore.instance
      .collection('ofertas')
      .doc('oferta_seed_v6_zona_norte')
      .get();
  if (!ofertaDoc.exists) {
    await seedData();
  }

  final patchDoc = await FirebaseFirestore.instance
      .collection('ofertas')
      .doc('patch_logos_v1')
      .get();
  if (!patchDoc.exists) {
    await patchInstitucionesSinLogo();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/editar-perfil': (context) => const EditProfileScreen(),
        '/historial': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return HistorialScreen(
            titulo: args?['titulo']?.toString() ?? 'Búsquedas recientes',
            tipo: args?['tipo']?.toString(),
          );
        },
        '/configuracion': (context) => const ConfiguracionScreen(),
        '/soporte': (context) => const AyudaSoporteScreen(),
        '/test': (context) => const TestVocacionalScreen(),
        '/test-resultados': (context) => const TestResultadosScreen(),
        '/map': (context) => const MapScreen(),
        '/institucion': (context) {
          final uid = ModalRoute.of(context)!.settings.arguments as String;
          return InstitucionDetailScreen(institucionUid: uid);
        },
      },
    );
  }
}
