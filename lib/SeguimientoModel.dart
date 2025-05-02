import 'package:cloud_firestore/cloud_firestore.dart';

class SeguimientoModel {
  String? id;
  String motivo;
  String observaciones;
  String? notas;
  String? imagen;
  String? imagen_2;
  DateTime fecha_creacion;
  String fkid_cultivo;
  
  SeguimientoModel({
    this.id,
    required this.motivo,
    required this.observaciones,
    this.notas,
    this.imagen,
    this.imagen_2,
    required this.fecha_creacion,
    required this.fkid_cultivo,
  });
  
  // Convertir Firestore Document a SeguimientoModel
  factory SeguimientoModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SeguimientoModel(
      id: doc.id,
      motivo: data['motivo'] ?? '',
      observaciones: data['observaciones'] ?? '',
      notas: data['notas'],
      imagen: data['imagen'],
      imagen_2: data['imagen_2'],
      fecha_creacion: (data['fecha_creacion'] as Timestamp).toDate(),
      fkid_cultivo: data['fkid_cultivo'] ?? '',
    );
  }
  
  // Convertir SeguimientoModel a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'motivo': motivo,
      'observaciones': observaciones,
      'notas': notas,
      'imagen': imagen,
      'imagen_2': imagen_2,
      'fecha_creacion': Timestamp.fromDate(fecha_creacion),
      'fkid_cultivo': fkid_cultivo,
    };
  }
}