import 'package:flutter/material.dart';
import 'HomeScreenApp.dart';
import 'package:flutter_application_1/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'RegisterCultivoScreen.dart'; // Importamos RegisterCultivoScreen

class RegisterScreen extends StatefulWidget {
  final String uid; // Recibimos el UID del usuario

  const RegisterScreen({super.key, required this.uid}); // Recibimos el uid en el constructor

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  // Instancia del servicio de Firebase
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Crea tu cuenta',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 30),
                // Correo electrónico
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    suffixIcon: Icon(Icons.email, color: Colors.green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Nombre de usuario
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Nombre de usuario'),
                ),
                SizedBox(height: 20),
                // Nombre(s)
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'Nombre(s)'),
                ),
                SizedBox(height: 20),
                // Apellido paterno
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Apellido paterno'),
                ),
                SizedBox(height: 20),
                // Apellido materno
                TextField(
                  controller: middleNameController,
                  decoration: InputDecoration(labelText: 'Apellido materno'),
                ),
                SizedBox(height: 20),
                // Fecha de nacimiento
                TextField(
                  controller: birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de nacimiento (DD/MM/AAAA)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      String formattedDate =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      setState(() {
                        birthDateController.text = formattedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                // Teléfono (opcional)
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Teléfono (opcional)'),
                ),
                SizedBox(height: 20),
                // Ubicación (opcional)
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación (opcional)',
                  ),
                ),
                SizedBox(height: 20),
                // Contraseña
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                ),
                SizedBox(height: 20),
                // Confirmar Contraseña
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                  ),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 20),
                // Botón de registro
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: isLoading ? null : _manualRegister,
                    child:
                        isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'REGISTRATE',
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿Ya tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Inicia sesión',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FUNCIÓN MANUAL PARA REGISTRAR USUARIOS SIN DEPENDER MUCHO DEL SERVICIO
  Future<void> _manualRegister() async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      // 1. Validaciones básicas
      if (nameController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty ||
          usernameController.text.isEmpty ||
          firstNameController.text.isEmpty ||
          lastNameController.text.isEmpty) {
        setState(() {
          errorMessage = 'Por favor, completa todos los campos obligatorios';
          isLoading = false;
        });
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          errorMessage = 'Las contraseñas no coinciden';
          isLoading = false;
        });
        return;
      }

      // 2. Crear usuario manualmente en Firebase Auth
      final email = nameController.text.trim();
      final password = passwordController.text;

      print('Intentando crear usuario en Auth...');

      // Crear usuario en Auth
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print('Usuario creado en Auth');
      } catch (authError) {
        print('Error en Auth: $authError');
        handleAuthError(authError);
        return;
      }

      // Pequeña pausa para asegurar que el usuario se crea correctamente
      await Future.delayed(Duration(milliseconds: 500));

      // Obtener el usuario actual
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = 'No se pudo obtener el usuario después de crearlo';
          isLoading = false;
        });
        return;
      }

      final userId = currentUser.uid;
      print('ID del usuario: $userId');

      // 3. Parsear fecha de nacimiento
      DateTime? birthDate;
      if (birthDateController.text.isNotEmpty) {
        try {
          final parts = birthDateController.text.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            birthDate = DateTime(year, month, day);
          }
        } catch (e) {
          print('Error al parsear fecha: $e');
        }
      }

      // 4. Preparar datos para Firestore
      final userData = {
        'id_usuario': userId,
        'nombre_usuario': usernameController.text,
        'nombre': firstNameController.text,
        'apellido_paterno': lastNameController.text,
        'apellido_materno': middleNameController.text,
        'correo': email,
        'fecha_registro': FieldValue.serverTimestamp(),
      };

      // Agregar campos opcionales
      if (birthDate != null) {
        userData['fecha_nacimiento'] = Timestamp.fromDate(birthDate);
      }

      if (phoneController.text.isNotEmpty) {
        userData['numero_telefono'] = phoneController.text;
      }

      if (locationController.text.isNotEmpty) {
        userData['ubicacion'] = locationController.text;
      }

      // 5. Guardar datos en Firestore manualmente
      print('Guardando datos en Firestore...');
      try {
        await FirebaseFirestore.instance
            .collection('Usuario')
            .doc(userId)
            .set(userData);

        print('Datos guardados exitosamente en Firestore');

        // Verificar que se guardaron los datos
        final docSnapshot =
            await FirebaseFirestore.instance
                .collection('Usuario')
                .doc(userId)
                .get();

        if (docSnapshot.exists) {
          print('Documento confirmado en Firestore: ${docSnapshot.data()}');

          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario registrado exitosamente')),
          );

          // Navegar a la pantalla principal
          await Future.delayed(Duration(seconds: 1));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreenApp(uid: userId)), // Pasamos el uid a HomeScreenApp
          );
        } else {
          throw Exception('No se pudo verificar el documento en Firestore');
        }
      } catch (firestoreError) {
        print('Error al guardar en Firestore: $firestoreError');
        setState(() {
          errorMessage = 'Error al guardar datos: $firestoreError';
        });

        // Si falla el guardado en Firestore, intentar eliminar el usuario de Auth
        try {
          await currentUser.delete();
          print('Usuario eliminado de Auth debido al error en Firestore');
        } catch (e) {
          print('No se pudo eliminar el usuario de Auth: $e');
        }
      }
    } catch (e) {
      print('Error general: $e');
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleAuthError(dynamic error) {
    String message = 'Error al crear cuenta';

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          message = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          message = 'Formato de correo inválido';
          break;
        case 'weak-password':
          message = 'La contraseña es muy débil';
          break;
        default:
          message = 'Error: ${error.message}';
      }
    }

    setState(() {
      errorMessage = message;
      isLoading = false;
    });
  }
}
