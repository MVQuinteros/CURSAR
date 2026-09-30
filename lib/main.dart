import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'screens/notificaciones_screen.dart';
import 'screens/test_vocacional_screen.dart';
import 'screens/test_resultados_screen.dart';
import 'screens/map_screen.dart';
import 'screens/institucion_detail_screen.dart';
import 'screens/explore_instituciones_screen.dart';
import 'screens/institucion_carreras_screen.dart';
import 'screens/favoritos_screen.dart';
import 'services/theme_controller.dart';
import 'theme/app_theme.dart';
import 'seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();

  // Las siembras son best-effort: si las reglas de Firestore no dejan leer o
  // escribir un marcador, la app tiene que arrancar igual.
  await _conSeed(
    'ofertas/oferta_seed_v6_zona_norte',
    seedData,
  );
  await _conSeed('ofertas/patch_logos_v1', patchInstitucionesSinLogo);
  await _conSeed(
    'instituciones/patch_assets_locales_v6',
    patchInstitucionesAssetsLocales,
  );
  await _conSeed(
    'ofertas/oferta_seed_v8_carreras_completas',
    seedCarrerasCompletas,
  );
  await _conSeed('instituciones/eliminar_isft180_v1', eliminarIsft180);
  await _conSeed(
    'instituciones/seed_instituciones_nuevas_v1',
    seedInstitucionesNuevas,
  );
  await _conSeed('instituciones/logos_storage_v1', seedLogosStorage);
  await _conSeed('avisos/avisos_seed_v1', seedAvisos);

  runApp(const MyApp());

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) return;
    _seedFavoritosEnLogin();
  });
}

/// Corre [semilla] solo si el documento [ruta] no existe todavia.
/// Cualquier error de red o de permisos se ignora.
Future<void> _conSeed(String ruta, Future<void> Function() semilla) async {
  try {
    final partes = ruta.split('/');
    final doc = await FirebaseFirestore.instance
        .collection(partes.first)
        .doc(partes.last)
        .get();
    if (doc.exists) return;
    await semilla();
  } catch (e) {
    debugPrint('Semilla $ruta omitida: $e');
  }
}

Future<void> _seedFavoritosEnLogin() async {
  try {
    final favoritosSeedDoc = await FirebaseFirestore.instance
        .collection('ofertas')
        .doc('favoritos_seed_v1')
        .get();
    if (favoritosSeedDoc.exists) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await seedFavoritosDemo(user.uid);
  } catch (e) {
    debugPrint('Semilla de favoritos omitida: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Proyecto App',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: ThemeController.instance.isDark
              ? ThemeMode.dark
              : ThemeMode.light,
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
        '/notificaciones': (context) => const NotificacionesScreen(),
        '/test': (context) => const TestVocacionalScreen(),
        '/test-resultados': (context) => const TestResultadosScreen(),
        '/map': (context) => const MapScreen(),
        '/institucion': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          String uid;
          String? ofertaFiltroId;
          if (args is String) {
            uid = args;
          } else if (args is Map) {
            uid = args['institucionUid']?.toString() ?? '';
            final ofertaId = args['ofertaId'];
            ofertaFiltroId = ofertaId?.toString();
          } else {
            uid = '';
          }
          return InstitucionDetailScreen(
            institucionUid: uid,
            ofertaFiltroId: ofertaFiltroId,
          );
        },
        '/explore-instituciones': (context) =>
            const ExploreInstitucionesScreen(),
        '/institucion-carreras': (context) {
          final uid = ModalRoute.of(context)!.settings.arguments as String;
          return InstitucionCarrerasScreen(institucionUid: uid);
        },
        '/favoritos': (context) => const FavoritesScreen(),
      },
        );
      },
    );
  }
}
