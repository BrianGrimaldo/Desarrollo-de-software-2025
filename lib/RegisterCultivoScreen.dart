import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Asegúrate de tener el servicio de Firebase importado
import 'CultivosScreen.dart';  // Importa la pantalla de cultivos para redirigir después del registro

class RegisterCultivoScreen extends StatefulWidget {
  final String uid; // Recibimos el UID del usuario

  // Constructor para recibir el UID del usuario
  const RegisterCultivoScreen({super.key, required this.uid});

  @override
  _RegisterCultivoScreenState createState() => _RegisterCultivoScreenState();
}

class _RegisterCultivoScreenState extends State<RegisterCultivoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController observacionesController = TextEditingController();
  final TextEditingController notasController = TextEditingController();
  final TextEditingController imagenController = TextEditingController();
  final TextEditingController imagen2Controller = TextEditingController();
  bool agregarRecordatorio = false;

  bool isLoading = false;

  // Método para guardar el cultivo en Firestore
  Future<void> _guardarCultivo() async {
    setState(() {
      isLoading = true;
    });

    // Validación de campos obligatorios
    if (nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('El nombre del cultivo es obligatorio')));
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Datos del cultivo
    Map<String, dynamic> cultivoData = {
      'nombre': nombreController.text,
      'precio': double.tryParse(precioController.text) ?? 0.0,
      'descripcion': descripcionController.text,
      'observaciones': observacionesController.text,
      'notas': notasController.text,
      'imagen': imagenController.text,
      'imagen_2': imagen2Controller.text,
      'fecha_creacion': Timestamp.now(),
      'fkid_usuario': widget.uid, // Usamos el UID del usuario
    };

    try {
      // Guardar el cultivo en Firestore
      await _firestore.collection('Cultivo').add(cultivoData);

      // Si se agregó el recordatorio, lo manejamos (opcional)
      if (agregarRecordatorio) {
        // Lógica para agregar recordatorio en el calendario
        // Esto debe implementarse según el sistema de calendario que uses
        print('Recordatorio agregado');
      }

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cultivo registrado exitosamente')));

      // Redirigir al agricultor a la lista de cultivos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CultivosScreen(uid: widget.uid)),  // Pasamos el uid
      );
    } catch (e) {
      print('Error al registrar el cultivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar el cultivo')));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Cultivo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre del cultivo'),
            ),
            TextField(
              controller: precioController,
              decoration: InputDecoration(labelText: 'Precio por kilogramo'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: observacionesController,
              decoration: InputDecoration(labelText: 'Observaciones'),
            ),
            TextField(
              controller: notasController,
              decoration: InputDecoration(labelText: 'Notas adicionales'),
            ),
            TextField(
              controller: imagenController,
              decoration: InputDecoration(labelText: 'Imagen URL 1'),
            ),
            TextField(
              controller: imagen2Controller,
              decoration: InputDecoration(labelText: 'Imagen URL 2'),
            ),
            Row(
              children: [
                Checkbox(
                  value: agregarRecordatorio,
                  onChanged: (bool? value) {
                    setState(() {
                      agregarRecordatorio = value!;
                    });
                  },
                ),
                Text('Agregar recordatorio al calendario')
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _guardarCultivo,
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}
