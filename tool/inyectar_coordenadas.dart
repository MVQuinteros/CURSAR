// Inyecta el campo `ubicacion` (GeoPoint) en las instituciones que se
// guardaron sin coordenadas.
//
// Por que hace falta: `InstitucionModel` lee bien las coordenadas, pero si el
// documento no tiene el campo, la latitud y la longitud llegan en null y
// `_calcularDistancias` (map_screen.dart) descarta la institucion en silencio,
// sin error ni log. El mapa mostraba 5 de 16 instituciones mientras "Explorar
// por institucion" mostraba las 16, y no habia forma de saber por que.
//
// Uso, desde la raiz del proyecto:
//
//   flutter run -t tool/inyectar_coordenadas.dart -d chrome --dart-define=DRYRUN=true
//   flutter run -t tool/inyectar_coordenadas.dart -d chrome
//
// Con DRYRUN no escribe nada: solo lista que haria.
//
// Es un entrypoint de Flutter aparte a proposito: `firebase_core` es un plugin
// que necesita el motor de Flutter, asi que no se puede correr con `dart run`.
// Reusa `initializeFirebase()` de lib/firebase_config.dart, o sea el mismo
// proyecto que la app.
//
// No borra documentos ni campos: solo agrega `ubicacion` donde falta, y nunca
// pisa una coordenada existente salvo que difiera de la de aca (y avisa).
// Es idempotente. Se puede borrar este archivo cuando la base quede bien.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:proyecto_app/firebase_config.dart';

/// Coordenadas de las instituciones que quedaron sin ubicacion.
///
/// Se toman como [latitud, longitud]. Son aproximadas a la manzana: alcanzan
/// para colocar el marcador y ordenar por distancia, que es lo que usa la app.
const Map<String, List<double>> _coordenadas = {
  'uba_cbc_sanmiguel': [-34.5423, -58.7133],
  'isfd112': [-34.5435, -58.7152],
  'isfd243': [-34.4988, -58.6944],
  'isfdyt36': [-34.5165, -58.7665],
  'isfdyt42': [-34.5418, -58.7148],
  'isnarcangel': [-34.5420, -58.7125],
  'itm_jcp': [-34.5140, -58.7660],
  'ucasal_sanmiguel': [-34.5440, -58.7160],
  'utn_pui_jcp': [-34.5150, -58.7670],
  'siglo21_sanmiguel': [-34.5430, -58.7120],
  'uflo_sanmiguel': [-34.5405, -58.7110],
  // Nuevas instituciones
  'modelo_bellavista': [-34.543, -58.712],
  'britanico_sanmiguel': [-34.544, -58.714],
  'paramedico_sanmiguel': [-34.543, -58.713],
  'sanjose_muniz': [-34.533, -58.703],
};

/// Lotes de escritura, para no mandar 2000 operaciones en un solo commit.
const int _tamanoLote = 200;

class _Informe {
  _Informe();

  final List<String> lineas = [];
  bool dryRun = false;
  String? error;

  int vistas = 0;

  /// Instituciones a las que hay que ponerles coordenada. En dry run es una
  /// intension; fuera de dry run, lo que se va a escribir.
  int aInyectar = 0;

  /// Las que ya tenian la coordenada correcta: no se tocan.
  int yaTenian = 0;

  /// Las que tenian otra coordenada y se van a pisar.
  int aSobrescribir = 0;

  int escritas = 0;
  int confirmadas = 0;
  int sinUid = 0;

  void log(String linea) {
    lineas.add(linea);
    debugPrint('[COORD] $linea');
  }
}

/// Un par invertido o fuera de rango produce un marcador en el mar, que es
/// peor que no tener marcador: no avisa, solo confunde. Se corta aca.
bool _valida(List<double> c) {
  if (c.length != 2) return false;
  if (c[0] < -90 || c[0] > 90) return false;
  if (c[1] < -180 || c[1] > 180) return false;
  return true;
}

Future<void> _correr(_Informe r) async {
  final db = FirebaseFirestore.instance;
  final ref = db.collection('instituciones');

  final snap = await ref.get();
  r.vistas = snap.docs.length;
  r.log('instituciones en la base: ${snap.docs.length}');

  final aEscribir = <MapEntry<DocumentReference<Map<String, dynamic>>, GeoPoint>>[];
  final vistos = <String>{};

  for (final doc in snap.docs) {
    final par = _coordenadas[doc.id];
    if (par == null) continue;
    vistos.add(doc.id);

    if (!_valida(par)) {
      r.log('  ERROR ${doc.id}: coordenada invalida $par, no se escribe');
      continue;
    }

    final actual = doc.data()['ubicacion'];
    final nuevo = GeoPoint(par[0], par[1]);

    if (actual is GeoPoint) {
      if (actual.latitude == par[0] && actual.longitude == par[1]) {
        r.yaTenian++;
        r.log('  ${doc.id}: ya correcta, no se toca');
        continue;
      }
      r.aSobrescribir++;
      r.log('  ${doc.id}: SOBRESCRIBE '
          '${actual.latitude},${actual.longitude} -> ${par[0]},${par[1]}');
    } else {
      r.aInyectar++;
      r.log('  ${doc.id}: SIN ubicacion (era ${actual.runtimeType}), '
          'se pone ${par[0]}, ${par[1]}');
    }

    aEscribir.add(MapEntry(doc.reference, nuevo));
  }

  for (final uid in _coordenadas.keys) {
    if (!vistos.contains(uid)) {
      r.sinUid++;
      r.log('  AVISO: el uid "$uid" no existe en la base');
    }
  }

  if (r.dryRun) {
    r.log('DRY RUN: no se escribio nada. Para escribir, correlo sin DRYRUN.');
    return;
  }

  if (aEscribir.isEmpty) {
    r.log('no hay nada que escribir');
  }

  for (var i = 0; i < aEscribir.length; i += _tamanoLote) {
    final lote = db.batch();
    final fin = (i + _tamanoLote) < aEscribir.length
        ? i + _tamanoLote
        : aEscribir.length;
    for (var j = i; j < fin; j++) {
      // update y no set: solo se toca `ubicacion`, el resto del documento queda
      // intacto, asi un dato guardado a mano no se pisa por el camino.
      lote.update(aEscribir[j].key, {'ubicacion': aEscribir[j].value});
    }
    await lote.commit();
    r.escritas += fin - i;
    r.log('commit OK: ${fin - i} documentos');
  }

  // Verificacion posterior: releer y probar que quedo guardado de verdad. Sin
  // esto, un "commit OK" del cliente no alcanza como prueba.
  r.log('--- verificacion releyendo la base ---');
  for (final par in _coordenadas.entries) {
    final doc = await ref.doc(par.key).get();
    final ubicacion = doc.data()?['ubicacion'];
    if (ubicacion is GeoPoint &&
        ubicacion.latitude == par.value[0] &&
        ubicacion.longitude == par.value[1]) {
      r.confirmadas++;
      r.log('  OK ${par.key}: ${ubicacion.runtimeType} '
          '${ubicacion.latitude}, ${ubicacion.longitude}');
    } else {
      r.log('  FALLO ${par.key}: quedo ${ubicacion.runtimeType} $ubicacion');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final r = _Informe()..dryRun = const bool.fromEnvironment('DRYRUN');

  try {
    await initializeFirebase();
    await _correr(r);
  } catch (e) {
    r.error = '$e';
  }
  runApp(_App(r));
}

class _App extends StatelessWidget {
  const _App(this.r);

  final _Informe r;

  @override
  Widget build(BuildContext context) {
    final titulo = r.error != null
        ? 'FALLO: ${r.error}'
        : r.dryRun
            ? 'DRY RUN - no se escribio nada'
            : (r.confirmadas == r.aInyectar + r.aSobrescribir
                ? 'ESCRITO Y VERIFICADO'
                : 'REVISAR: escrituras sin confirmar');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF101828),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dry run: ${r.dryRun ? "SI (no escribio)" : "no"}\n'
                  'Documentos vistos: ${r.vistas}\n'
                  'A inyectar: ${r.aInyectar}\n'
                  'A sobrescribir: ${r.aSobrescribir}\n'
                  'Ya correctas: ${r.yaTenian}\n'
                  'Uids ausentes: ${r.sinUid}\n'
                  'ESCRITAS: ${r.escritas}\n'
                  'CONFIRMADAS al releer: ${r.confirmadas}',
                  style: const TextStyle(
                    color: Color(0xFF58B2FF),
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      r.lineas.join('\n'),
                      style: const TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 12,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
