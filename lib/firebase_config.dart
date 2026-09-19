import 'package:firebase_core/firebase_core.dart';

// Estos son los datos específicos de tu nuevo proyecto-app
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyDi9eDrS4MupboINvALOnzE63EsLW8xDLE', // La encuentras en "Ver las instrucciones del SDK"
  authDomain: 'proyecto-app.firebaseapp.com',
  projectId: 'proyecto-app-a77c8',
  storageBucket: 'proyecto-app.appspot.com',
  messagingSenderId: '642247955799', // Extraído de tu ID de app
  appId: '1:642247955799:android:da24b0de4e913bef475a12', // Extraído de tu captura
);

Future<void> initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: firebaseOptions);
      print("Firebase inicializado correctamente.");
    } else {
      print("Firebase ya estaba inicializado.");
    }
  } catch (e) {
    print("Error al inicializar Firebase: $e");
  }
}