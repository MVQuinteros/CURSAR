import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reporte_model.dart';

class SoporteService {
  Future<void> enviarReporte(ReporteModel reporte) async {
    final mapa = reporte.toMap();
    mapa['createdAt'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance.collection('soporte').add(mapa);
  }
}