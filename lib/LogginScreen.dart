import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'HomeScreenApp.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _uid; // Para almacenar el uid del usuario logueado

  // Método para manejar el login
  Future<void> _login() async {
    try {
      // Verificar si los campos no están vacíos
      if (nameController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, ingresa tus credenciales')),
        );
        return;
      }

      // Intentar hacer el login con el correo y contraseña
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: nameController.text,
        password: passwordController.text,
      );

      // Verificar si el login fue exitoso
      if (userCredential.user != null) {
        // Guardamos el UID del usuario logueado
        setState(() {
          _uid = userCredential.user!.uid;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido ${userCredential.user!.email}')),
        );

        // Navegar a la pantalla principal (HomeScreenApp) pasando el UID
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreenApp(uid: _uid!), // Asegúrate de pasar el uid aquí
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión')),
        );
      }
    } catch (e) {
      print('Error de login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de login: $e')),
      );
    }
  }

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
                  'Vamos a fortalecer el campo',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    suffixIcon: Icon(Icons.check, color: Colors.green),
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
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    Text('Remember me'),
                    Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?'),
                    ),
                  ],
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
                    onPressed: _login, // Llamamos al método _login cuando se presiona el botón
                    child: Text('LOGIN', style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('¿No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          // Navegar a la pantalla de registro, pasando el `uid` vacío
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(uid: _uid ?? ''), // Pasamos el uid vacío o válido
                            ),
                          );
                        },
                        child: Text(
                          'Regístrate',
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
