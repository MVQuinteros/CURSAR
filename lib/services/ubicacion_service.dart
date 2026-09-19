import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'preferencias_service.dart';

enum ModoViaje { auto, caminando, transporte }

extension ModoViajeX on ModoViaje {
  String get travelmode => switch (this) {
        ModoViaje.auto => 'driving',
        ModoViaje.caminando => 'walking',
        ModoViaje.transporte => 'transit',
      };
}

class TiemposViaje {
  final int autoMin;
  final int caminandoMin;
  final int transporteMin;

  const TiemposViaje({
    required this.autoMin,
    required this.caminandoMin,
    required this.transporteMin,
  });
}

class UbicacionService {
  static const int _radioPorDefecto = 20;
  static const double _velAuto = 30.0;
  static const double _velCamino = 5.0;
  static const double _velTransporte = 20.0;
  static const double _factorRuta = 1.3;

  static double distanciaKm(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _aRadianes(lat2 - lat1);
    final dLng = _aRadianes(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_aRadianes(lat1)) *
            math.cos(_aRadianes(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static TiemposViaje tiempos(double km) {
    final dist = km.clamp(0.0, double.infinity) * _factorRuta;
    return TiemposViaje(
      autoMin: (dist / _velAuto * 60).round(),
      caminandoMin: (dist / _velCamino * 60).round(),
      transporteMin: (dist / _velTransporte * 60).round(),
    );
  }

  static String formatearKm(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static Future<Position?> obtenerPosicion() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<int> obtenerRadioBusqueda() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _radioPorDefecto;
    try {
      final prefs = await PreferenciasService().obtener(user.uid);
      final radio = prefs.radioBusqueda;
      return radio <= 0 ? _radioPorDefecto : radio;
    } catch (_) {
      return _radioPorDefecto;
    }
  }

  static double _aRadianes(double grados) => grados * math.pi / 180;
}