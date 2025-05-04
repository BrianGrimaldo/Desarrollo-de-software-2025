import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'CultivosScreen.dart';

class RegisterCultivoScreen extends StatefulWidget {
  final String uid;

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
  bool isVerifyingUser = true;
  String? correctUserId;

  @override
  void initState() {
    super.initState();
    _verificarUsuario();
  }

  Future<void> _verificarUsuario() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Usuario').doc(widget.uid).get();

      if (userDoc.exists) {
        setState(() {
          correctUserId = widget.uid;
          isVerifyingUser = false;
        });
        print('ID de usuario verificado: $correctUserId');
        return;
      }

      QuerySnapshot userQuery =
          await _firestore
              .collection('Usuario')
              .where('id_usuario', isEqualTo: widget.uid)
              .limit(1)
              .get();

      if (userQuery.docs.isNotEmpty) {
        setState(() {
          correctUserId = userQuery.docs.first.id;
          isVerifyingUser = false;
        });
        print('ID de usuario encontrado por consulta: $correctUserId');
        return;
      }

      QuerySnapshot allUsersQuery =
          await _firestore.collection('Usuario').get();

      for (var doc in allUsersQuery.docs) {
        if (doc.id == widget.uid ||
            (doc.data() as Map<String, dynamic>)['id_usuario'] == widget.uid) {
          setState(() {
            correctUserId = doc.id;
            isVerifyingUser = false;
          });
          print(
            'ID de usuario encontrado en todos los usuarios: $correctUserId',
          );
          return;
        }
      }

      setState(() {
        correctUserId = widget.uid;
        isVerifyingUser = false;
      });
      print('Usando ID de usuario original: $correctUserId');
    } catch (e) {
      print('Error al verificar usuario: $e');
      setState(() {
        correctUserId = widget.uid;
        isVerifyingUser = false;
      });
    }
  }

  Future<void> _guardarCultivo() async {
    setState(() {
      isLoading = true;
    });

    if (nombreController.text.isEmpty) {
      _mostrarSnackBar('El nombre del cultivo es obligatorio', isError: true);
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (correctUserId == null) {
      await _verificarUsuario();
    }

    // Mostrar un diálogo de carga mientras se guarda
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CAF50),
                    ),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Registrando cultivo",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Por favor, espere...",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Map<String, dynamic> cultivoData = {
      'nombre': nombreController.text,
      'precio': double.tryParse(precioController.text) ?? 0.0,
      'descripcion': descripcionController.text,
      'observaciones': observacionesController.text,
      'notas': notasController.text,
      'imagen': imagenController.text,
      'imagen2': imagen2Controller.text,
      'fecha_creacion': Timestamp.now(),
      'fkid_usuario': correctUserId ?? widget.uid,
      'daysTranscurridos': 0,
      'alertStatus': 'Normal',
    };

    try {
      DocumentReference docRef = await _firestore
          .collection('Cultivo')
          .add(cultivoData);

      print('Cultivo registrado con ID: ${docRef.id}');
      print('Usando fkid_usuario: ${correctUserId ?? widget.uid}');

      if (agregarRecordatorio) {
        print('Recordatorio agregado');
      }

      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      _mostrarSnackBar('Cultivo registrado exitosamente', isSuccess: true);

      // Pequeño retraso para permitir ver el mensaje
      await Future.delayed(Duration(milliseconds: 1500));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CultivosScreen(uid: widget.uid),
        ),
      );
    } catch (e) {
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();

      print('Error al registrar el cultivo: $e');
      _mostrarSnackBar('Error al registrar el cultivo: $e', isError: true);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _mostrarSnackBar(
    String mensaje, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    Color backgroundColor = Colors.grey;
    IconData iconData = Icons.info_outline;

    if (isError) {
      backgroundColor = Colors.red;
      iconData = Icons.error_outline;
    } else if (isSuccess) {
      backgroundColor = Color(0xFF43A047);
      iconData = Icons.check_circle;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(mensaje, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cambiar el color de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Color(
        0xFFF7F9F4,
      ), // Fondo crema claro para temática agrícola
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF4CAF50),
        title: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Nuevo Cultivo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body:
          isVerifyingUser
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Verificando usuario...',
                      style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              )
              : SafeArea(
                child: Column(
                  children: [
                    // Banner informativo
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFA5D6A7), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Completa la información para registrar tu nuevo cultivo. Los campos con * son obligatorios.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Campos de formulario
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildInputField(
                            controller: nombreController,
                            label: 'Nombre del cultivo *',
                            icon: Icons.spa,
                            hint: 'Ej: Tomate Roma',
                            required: true,
                          ),
                          _buildInputField(
                            controller: precioController,
                            label: 'Precio por kilogramo',
                            icon: Icons.attach_money,
                            hint: 'Ej: 25.50',
                            keyboardType: TextInputType.number,
                          ),
                          _buildInputField(
                            controller: descripcionController,
                            label: 'Descripción',
                            icon: Icons.description,
                            hint: 'Describe tu cultivo',
                            maxLines: 3,
                          ),
                          _buildInputField(
                            controller: observacionesController,
                            label: 'Observaciones',
                            icon: Icons.visibility,
                            hint: 'Observaciones importantes',
                            maxLines: 2,
                          ),
                          _buildInputField(
                            controller: notasController,
                            label: 'Notas adicionales',
                            icon: Icons.note,
                            hint: 'Cualquier información adicional',
                          ),
                          _buildInputField(
                            controller: imagenController,
                            label: 'URL de imagen principal',
                            icon: Icons.image,
                            hint: 'https://ejemplo.com/imagen.jpg',
                          ),
                          _buildInputField(
                            controller: imagen2Controller,
                            label: 'URL de imagen secundaria',
                            icon: Icons.collections,
                            hint: 'https://ejemplo.com/imagen2.jpg',
                          ),

                          // Checkbox para recordatorio
                          Container(
                            margin: EdgeInsets.only(top: 16, bottom: 8),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF4CAF50),
                                  size: 24,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Agregar recordatorio al calendario',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: agregarRecordatorio,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      agregarRecordatorio = value!;
                                    });
                                  },
                                  activeColor: Color(0xFF4CAF50),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),

                    // Botón de registrar
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _guardarCultivo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[400],
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              Icon(Icons.check_circle),
                            SizedBox(width: 8),
                            Text(
                              isLoading
                                  ? 'Registrando...'
                                  : 'Registrar Cultivo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  // Widget para crear campos de formulario con estilo uniforme
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = '',
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: Color(0xFF4CAF50), size: 20),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                if (required)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
