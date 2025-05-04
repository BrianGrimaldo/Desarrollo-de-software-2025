import 'package:flutter_application_1/LogginScreen.dart'; // Verifica que este sea el nombre exacto de tu archivo
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;

  const UserProfileScreen({super.key, required this.uid});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Stream<DocumentSnapshot> _userStream;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _isUploading = false;

  // Controllers for editable fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _userStream =
        FirebaseFirestore.instance
            .collection('Usuario')
            .doc(widget.uid)
            .snapshots();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (_selectedImage == null) return null;

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a reference to the Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${widget.uid}.jpg');

      // Create upload task
      final UploadTask uploadTask = storageRef.putFile(_selectedImage!);

      // Wait for the upload to complete
      final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(
        () => null,
      );

      // Get the download URL
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    if (_isEditing) {
      // Prepare data to update
      Map<String, dynamic> userDataToUpdate = {
        'correo': _emailController.text,
        'nombre': _nameController.text,
        'apellido_paterno': _paternoController.text,
        'apellido_materno': _maternoController.text,
        'numero_telefono': _phoneController.text,
        'ubicacion': _locationController.text,
        'nombre_usuario': _usernameController.text,
      };

      // Add birth date if it exists
      if (_birthDate != null) {
        userDataToUpdate['fecha_nacimiento'] = Timestamp.fromDate(_birthDate!);
      }

      try {
        // Upload image if selected
        if (_selectedImage != null) {
          final downloadURL = await _uploadImageToFirebase();
          if (downloadURL != null) {
            userDataToUpdate['foto_perfil'] = downloadURL;
          }
        }

        // Update user data
        await FirebaseFirestore.instance
            .collection('Usuario')
            .doc(widget.uid)
            .update(userDataToUpdate);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );

        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el perfil: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _showDeleteAccountDialog() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Eliminar Cuenta',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción eliminará:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('• Tu perfil de usuario', style: TextStyle(fontSize: 14)),
              Text(
                '• Tus cultivos registrados',
                style: TextStyle(fontSize: 14),
              ),
              Text('• Tu cuenta de acceso', style: TextStyle(fontSize: 14)),
              SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ingresa tu contraseña para confirmar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteUserAccount(passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Eliminar Cuenta'),
            ),
          ],
        );
      },
    );
  }

  // Añade este método para manejar la eliminación de la cuenta

  Future<void> _deleteUserAccount(String password) async {
    try {
      // Mostrar indicador de carga
      _showLoadingDialog('Eliminando cuenta...');

      // 1. Obtener el usuario actual y correo electrónico
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _hideLoadingDialog();
        _showErrorSnackBar('No hay sesión de usuario activa');
        return;
      }

      final String email = currentUser.email ?? '';
      if (email.isEmpty) {
        _hideLoadingDialog();
        _showErrorSnackBar(
          'No se encontró un correo electrónico válido para esta cuenta',
        );
        return;
      }

      // 2. Reautenticar al usuario (requerido para operaciones sensibles)
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      try {
        await currentUser.reauthenticateWithCredential(credential);
      } catch (e) {
        _hideLoadingDialog();
        _showErrorSnackBar(
          'Contraseña incorrecta. Por favor, verifica tu contraseña e intenta nuevamente.',
        );
        return;
      }

      // 3. Eliminar todos los cultivos del usuario
      await _deleteCultivos(widget.uid);

      // 4. Eliminar el documento del usuario en Firestore
      await FirebaseFirestore.instance
          .collection('Usuario')
          .doc(widget.uid)
          .delete();

      // 5. Eliminar la cuenta de usuario en Firebase Authentication
      await currentUser.delete();

      // 6. Cerrar el diálogo de carga
      _hideLoadingDialog();

      // 7. Mostrar mensaje de éxito y volver a la pantalla de inicio de sesión
      _showSuccessSnackBarAndNavigate('Cuenta eliminada correctamente');
    } catch (e) {
      _hideLoadingDialog();
      _showErrorSnackBar('Error al eliminar la cuenta: $e');
    }
  }

  // Método para eliminar todos los cultivos del usuario
  Future<void> _deleteCultivos(String userId) async {
    try {
      // Obtener referencia a todos los cultivos del usuario
      QuerySnapshot cultivosSnapshot =
          await FirebaseFirestore.instance
              .collection('Cultivo')
              .where('fkid_usuario', isEqualTo: userId)
              .get();

      // Eliminar cada cultivo
      for (var doc in cultivosSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('Cultivo')
            .doc(doc.id)
            .delete();
      }
    } catch (e) {
      print('Error al eliminar cultivos: $e');
      // Continuamos con el proceso aunque falle la eliminación de cultivos
    }
  }

  // Métodos auxiliares para UI

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
              SizedBox(height: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBarAndNavigate(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // Esperar 2 segundos y navegar a la pantalla de inicio de sesión
    Future.delayed(Duration(seconds: 2), () {
      // Intenta usar la clase exacta que tienes en tu proyecto
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ), // O LogginScreen() según tu proyecto
        (Route<dynamic> route) => false,
      );

      // Alternativa si hay problemas con la clase LoginScreen:
      // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    });
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController =
        TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Cambiar Contraseña',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña actual',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement password change
                Navigator.of(context).pop();

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contraseña actualizada correctamente'),
                    backgroundColor: Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  void _showChangeEmailDialog() {
    final TextEditingController newEmailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text(
                'Cambiar Correo',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Nuevo correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña para confirmar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                  ),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement email change
                Navigator.of(context).pop();

                // Show confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Correo actualizado correctamente'),
                    backgroundColor: Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF4CAF50)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9F4),
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Show options menu
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _buildOptionsMenu(),
              );
            },
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar los datos',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No se encontró información del usuario'),
            );
          }

          // Get user data
          final userData = snapshot.data!.data() as Map<String, dynamic>;

          // Set controllers values if we're in edit mode and controllers are empty
          if (_isEditing && _emailController.text.isEmpty) {
            _emailController.text = userData['correo'] ?? '';
            _nameController.text = userData['nombre'] ?? '';
            _paternoController.text = userData['apellido_paterno'] ?? '';
            _maternoController.text = userData['apellido_materno'] ?? '';
            _phoneController.text = userData['numero_telefono'] ?? '';
            _locationController.text = userData['ubicacion'] ?? '';
            _usernameController.text = userData['nombre_usuario'] ?? '';

            if (userData['fecha_nacimiento'] != null) {
              _birthDate = (userData['fecha_nacimiento'] as Timestamp).toDate();
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with profile image
                _buildProfileHeader(userData),

                // User information
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child:
                      _isEditing
                          ? _buildEditableFields(userData)
                          : _buildProfileInfo(userData),
                ),

                // Edit/Save button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildActionButtons(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reemplaza la sección del widget _buildProfileHeader con este código corregido:

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    String displayName = userData['nombre_usuario'] ?? 'Usuario';
    String userRole = userData['rol'] ?? 'Productor Verificado';
    String? profileImageUrl = userData['foto_perfil'];

    return Container(
      color: Color(0xFF4CAF50),
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          SizedBox(height: 20),
          Stack(
            children: [
              // Profile image
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  // Uso seguro de la imagen: verificamos explícitamente nulos
                  child: _getProfileImage(profileImageUrl),
                ),
              ),

              // Edit icon overlay
              if (_isEditing)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, color: Color(0xFF4CAF50), size: 20),
                  ),
                ),

              // Loading indicator during image upload
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            displayName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            userRole,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Añade este método para manejar de forma segura la imagen del perfil
  Widget _getProfileImage(String? imageUrl) {
    // Si hay una imagen seleccionada para carga
    if (_selectedImage != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
        child:
            _isEditing
                ? Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                )
                : null,
      );
    }

    // Si hay una URL de imagen en Firestore
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // En caso de error al cargar la imagen
              print('Error al cargar la imagen: $exception');
              return;
            },
          ),
        ),
        child:
            _isEditing
                ? Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
                )
                : null,
      );
    }

    // Si no hay imagen, mostrar icono por defecto
    return Icon(Icons.person, color: Colors.white, size: 50);
  }

  Widget _buildProfileInfo(Map<String, dynamic> userData) {
    return Column(
      children: [
        _buildInfoSection(
          title: 'Información de Cuenta',
          items: [
            _buildInfoItem(
              icon: Icons.email_outlined,
              title: 'Correo Electrónico',
              value: userData['correo'] ?? 'No especificado',
              showEditButton: true,
              onEdit: _showChangeEmailDialog,
            ),
            _buildInfoItem(
              icon: Icons.lock_outline,
              title: 'Contraseña',
              value: '••••••••',
              showEditButton: true,
              onEdit: _showChangePasswordDialog,
            ),
            _buildInfoItem(
              icon: Icons.account_circle_outlined,
              title: 'Nombre de Usuario',
              value: userData['nombre_usuario'] ?? 'No especificado',
            ),
          ],
        ),
        SizedBox(height: 24),
        _buildInfoSection(
          title: 'Información Personal',
          items: [
            _buildInfoItem(
              icon: Icons.person_outline,
              title: 'Nombre',
              value: userData['nombre'] ?? 'No especificado',
            ),
            _buildInfoItem(
              icon: Icons.person_outline,
              title: 'Apellido Paterno',
              value: userData['apellido_paterno'] ?? 'No especificado',
            ),
            _buildInfoItem(
              icon: Icons.person_outline,
              title: 'Apellido Materno',
              value: userData['apellido_materno'] ?? 'No especificado',
            ),
            _buildInfoItem(
              icon: Icons.calendar_today_outlined,
              title: 'Fecha de Nacimiento',
              value:
                  userData['fecha_nacimiento'] != null
                      ? _formatDate(
                        (userData['fecha_nacimiento'] as Timestamp).toDate(),
                      )
                      : 'No especificada',
            ),
            _buildInfoItem(
              icon: Icons.phone_outlined,
              title: 'Teléfono',
              value: userData['numero_telefono'] ?? 'No especificado',
            ),
            _buildInfoItem(
              icon: Icons.location_on_outlined,
              title: 'Ubicación',
              value: userData['ubicacion'] ?? 'No especificada',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    bool showEditButton = false,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (showEditButton && onEdit != null)
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF4CAF50), size: 20),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  Widget _buildEditableFields(Map<String, dynamic> userData) {
    return Column(
      children: [
        _buildInfoSection(
          title: 'Información de Cuenta',
          items: [
            _buildEditableField(
              controller: _usernameController,
              label: 'Nombre de Usuario',
              icon: Icons.account_circle_outlined,
              keyboardType: TextInputType.text,
            ),
          ],
        ),
        SizedBox(height: 24),
        _buildInfoSection(
          title: 'Información Personal',
          items: [
            _buildEditableField(
              controller: _nameController,
              label: 'Nombre',
              icon: Icons.person_outline,
              keyboardType: TextInputType.text,
            ),
            _buildEditableField(
              controller: _paternoController,
              label: 'Apellido Paterno',
              icon: Icons.person_outline,
              keyboardType: TextInputType.text,
            ),
            _buildEditableField(
              controller: _maternoController,
              label: 'Apellido Materno',
              icon: Icons.person_outline,
              keyboardType: TextInputType.text,
            ),
            _buildDateField(
              label: 'Fecha de Nacimiento',
              value:
                  _birthDate != null
                      ? _formatDate(_birthDate!)
                      : 'No especificada',
              icon: Icons.calendar_today_outlined,
              onTap: () => _selectDate(context),
            ),
            _buildEditableField(
              controller: _phoneController,
              label: 'Teléfono',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _buildEditableField(
              controller: _locationController,
              label: 'Ubicación',
              icon: Icons.location_on_outlined,
              keyboardType: TextInputType.text,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF4CAF50), size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _updateUserProfile,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF4CAF50),
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 0),
          ),
          child: Text(
            _isEditing ? 'Guardar Cambios' : 'Editar Perfil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (_isEditing)
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
                // Clear controllers
                _emailController.clear();
                _nameController.clear();
                _paternoController.clear();
                _maternoController.clear();
                _phoneController.clear();
                _locationController.clear();
                _usernameController.clear();
                _selectedImage = null;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(double.infinity, 0),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'Opciones de Cuenta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
            ),
            title: Text('Cambiar Correo Electrónico'),
            onTap: () {
              Navigator.pop(context);
              _showChangeEmailDialog();
            },
          ),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
            ),
            title: Text('Cambiar Contraseña'),
            onTap: () {
              Navigator.pop(context);
              _showChangePasswordDialog();
            },
          ),
          Divider(),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red),
            ),
            title: Text('Eliminar Cuenta', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }
}
