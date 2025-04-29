import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    suffixIcon: Icon(Icons.email, color: Colors.green),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                  ),
                ),
                SizedBox(height: 20),
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
                    onPressed: () async {
                      String email = nameController.text;
                      String password = passwordController.text;
                      String confirmPassword = confirmPasswordController.text;

                      if (email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty) {
                        // Asegúrate de que los campos no estén vacíos
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                  'Por favor, llena todos los campos',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cerrar'),
                                  ),
                                ],
                              ),
                        );
                        return;
                      }

                      if (password != confirmPassword) {
                        // Verifica si las contraseñas coinciden
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text('Error'),
                                content: Text('Las contraseñas no coinciden'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cerrar'),
                                  ),
                                ],
                              ),
                        );
                        return;
                      }

                      try {
                        // Registra al usuario en Firebase
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );

                        // Si el registro es exitoso, navega a la pantalla principal
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ), // Cambia a tu pantalla principal
                        );
                      } on FirebaseAuthException catch (e) {
                        String errorMessage = 'Ocurrió un error.';

                        if (e.code == 'weak-password') {
                          errorMessage = 'La contraseña es demasiado débil.';
                        } else if (e.code == 'email-already-in-use') {
                          errorMessage =
                              'Este correo electrónico ya está registrado.';
                        }

                        // Muestra el error en un cuadro de diálogo
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text('Error'),
                                content: Text(errorMessage),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Cerrar'),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                    child: Text(
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
                          // Volver a la pantalla de login
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
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bienvenido")),
      body: Center(child: Text("Pantalla principal")),
    );
  }
}
