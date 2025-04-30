import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método separado para crear usuario en Auth
  Future<String?> createUserAuth(String email, String password) async {
    try {
      print('Creando usuario en Auth...');
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Esperar a que se actualice el usuario actual
      await Future.delayed(Duration(milliseconds: 500));

      final user = _auth.currentUser;
      if (user != null) {
        print('Usuario creado en Auth con ID: ${user.uid}');
        return user.uid;
      } else {
        print('No se pudo obtener el usuario después de crearlo');
        return null;
      }
    } catch (e) {
      print('Error al crear usuario en Auth: $e');
      rethrow;
    }
  }

  // Método separado para guardar datos en Firestore
  Future<bool> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      print('Guardando datos en Firestore para usuario $uid');

      // Asegurar que el ID esté en los datos
      userData['id_usuario'] = uid;

      // Guardar en Firestore
      await _firestore.collection('Usuario').doc(uid).set(userData);

      // Verificar que se guardó
      print('Verificando que los datos se guardaron...');
      final doc = await _firestore.collection('Usuario').doc(uid).get();

      if (doc.exists) {
        print('Datos guardados exitosamente: ${doc.data()}');
        return true;
      } else {
        print('ERROR: No se encontró el documento después de guardarlo');
        return false;
      }
    } catch (e) {
      print('Error al guardar datos en Firestore: $e');
      rethrow;
    }
  }

  // Método simplificado para registro
  Future<bool> registerUser({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Paso 1: Crear usuario en Auth
      final uid = await createUserAuth(email, password);

      if (uid == null) {
        print('No se pudo crear el usuario en Auth');
        return false;
      }

      // Paso 2: Guardar datos en Firestore
      final success = await saveUserData(uid, userData);

      return success;
    } catch (e) {
      print('Error en proceso de registro: $e');
      rethrow;
    }
  }
}
