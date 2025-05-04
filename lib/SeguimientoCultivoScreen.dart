import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'SeguimientoModel.dart'; // Importar el modelo que creamos


class SeguimientoCultivoScreen extends StatefulWidget {
  final String cultivoId;
  final String cultivoNombre;

  const SeguimientoCultivoScreen({
    Key? key,
    required this.cultivoId,
    required this.cultivoNombre,
  }) : super(key: key);

  @override
  _SeguimientoCultivoScreenState createState() => _SeguimientoCultivoScreenState();
}
class _SeguimientoCultivoScreenState extends State<SeguimientoCultivoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Cambiar el color de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Color(0xFFF7F9F4), // Fondo crema claro
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF4CAF50), // Verde agricultura
        title: Row(
          children: [
            Icon(Icons.trending_up, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Seguimiento de Cultivo',
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
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Muestra información de ayuda
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Ayuda'),
                  content: Text(
                    'Esta pantalla muestra el historial de seguimiento del cultivo. Puedes registrar nuevo seguimiento usando el botón de abajo.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF388E3C),
              ),
            )
          : Column(
              children: [
                // Banner del cultivo
                _buildCultivoBanner(),
                
                // Lista de seguimientos
                _buildSeguimientosList(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarFormularioSeguimiento(context);
        },
        backgroundColor: Color(0xFF4CAF50),
        elevation: 4,
        icon: Icon(Icons.add_chart, color: Colors.white),
        label: Text('Nuevo Seguimiento', style: TextStyle(color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Banner del cultivo
  Widget _buildCultivoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF81C784), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.grass,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cultivoNombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  'Historial de seguimiento',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Seguimiento')
                  .where('fkid_cultivo', isEqualTo: widget.cultivoId)
                  .snapshots(),
              builder: (context, snapshot) {
                int count = 0;
                if (snapshot.hasData) {
                  count = snapshot.data!.docs.length;
                }
                return Text(
                  '$count registros',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Lista de seguimientos
  Widget _buildSeguimientosList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Seguimiento')
            .where('fkid_cultivo', isEqualTo: widget.cultivoId)
            .orderBy('fecha_creacion', descending: true)
            .snapshots(),
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
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Error al cargar los seguimientos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Color(0xFF4CAF50),
                      size: 60,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No hay registros de seguimiento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca el botón "Nuevo Seguimiento" para añadir',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Mostrar lista de seguimientos
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 80), // Espacio para FAB
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var seguimiento = snapshot.data!.docs[index];
              Map<String, dynamic> datos = seguimiento.data() as Map<String, dynamic>;
              
              Timestamp fechaTimestamp = datos['fecha_creacion'] as Timestamp;
              DateTime fecha = fechaTimestamp.toDate();
              String motivo = datos['motivo'] ?? 'Sin motivo';
              String observaciones = datos['observaciones'] ?? 'Sin observaciones';
              String? imagen = datos['imagen'];
              String? imagen2 = datos['imagen_2'];
              
              // Crear una lista de imágenes no nulas
              List<String> imageUrls = [];
              if (imagen != null && imagen.isNotEmpty) {
                imageUrls.add(imagen);
              }
              if (imagen2 != null && imagen2.isNotEmpty) {
                imageUrls.add(imagen2);
              }
              
              return _buildSeguimientoCard(
                id: seguimiento.id,
                fecha: fecha,
                motivo: motivo,
                observaciones: observaciones,
                imageUrls: imageUrls,
                notas: datos['notas'],
              );
            },
          );
        },
      ),
    );
  }
  
  // Tarjeta para cada seguimiento
  Widget _buildSeguimientoCard({
    required String id,
    required DateTime fecha,
    required String motivo,
    required String observaciones,
    required List<String> imageUrls,
    String? notas,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con fecha
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF388E3C).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF388E3C), size: 18),
                SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(fecha),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Spacer(),
                Text(
                  DateFormat('hh:mm a').format(fecha),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Motivo del seguimiento
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.subject, color: Color(0xFF4CAF50), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motivo:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        motivo,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Observaciones
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note_alt_outlined, color: Color(0xFF4CAF50), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observaciones:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        observaciones,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notas adicionales (si existen)
          if (notas != null && notas.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined, color: Color(0xFF4CAF50), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notas adicionales:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          notas,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Imágenes (si hay)
          if (imageUrls.isNotEmpty)
            Container(
              height: 120,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE0E0E0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          // Botones de acción
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Ver detalles completos
                    _verDetalleSeguimiento(
                      context,
                      id,
                      fecha,
                      motivo,
                      observaciones,
                      imageUrls,
                      notas,
                    );
                  },
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('Ver detalles'),
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF4CAF50),
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // Eliminar registro
                    _confirmarEliminacion(context, id);
                  },
                  icon: Icon(Icons.delete_outline, size: 18),
                  label: Text('Eliminar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para ver detalles completos de un seguimiento
  void _verDetalleSeguimiento(
    BuildContext context,
    String id,
    DateTime fecha,
    String motivo,
    String observaciones,
    List<String> imageUrls,
    String? notas,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalles del Seguimiento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              
              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha y hora
                      _buildDetailItem(
                        'Fecha y hora:',
                        DateFormat('dd/MM/yyyy - hh:mm a').format(fecha),
                        Icons.calendar_today,
                      ),
                      SizedBox(height: 16),
                      
                      // Motivo
                      _buildDetailItem(
                        'Motivo:',
                        motivo,
                        Icons.subject,
                      ),
                      SizedBox(height: 16),
                      
                      // Observaciones
                      _buildDetailItem(
                        'Observaciones:',
                        observaciones,
                        Icons.note_alt_outlined,
                      ),
                      SizedBox(height: 16),
                      
                      // Notas (si hay)
                      if (notas != null && notas.isNotEmpty) ...[
                        _buildDetailItem(
                          'Notas adicionales:',
                          notas,
                          Icons.sticky_note_2_outlined,
                        ),
                        SizedBox(height: 16),
                      ],
                      
                      // Imágenes (si hay)
                      if (imageUrls.isNotEmpty) ...[
                        _buildSectionTitle('Fotografías:', Icons.photo_library),
                        SizedBox(height: 8),
                        // Grid de imágenes
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                // Mostrar imagen ampliada
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.all(10),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            InteractiveViewer(
                                              panEnabled: true,
                                              boundaryMargin: EdgeInsets.all(80),
                                              minScale: 0.5,
                                              maxScale: 4,
                                              child: Image.network(
                                                imageUrls[index],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Color(0xFFE0E0E0)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                    ),
                ),
              ),
              
              // Botones de acción
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmarEliminacion(context, id);
                    },
                    icon: Icon(Icons.delete_outline),
                    label: Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.check),
                    label: Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget para construir un ítem de detalle
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label, icon),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFFDCEDC8),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF212121),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Widget para título de sección
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF4CAF50), size: 20),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  // Mostrar formulario para agregar nuevo seguimiento
  void _mostrarFormularioSeguimiento(BuildContext context) {
    // Controladores para el formulario
    TextEditingController motivoController = TextEditingController();
    TextEditingController observacionesController = TextEditingController();
    TextEditingController notasController = TextEditingController();
    
    // Fecha actual para el nuevo seguimiento
    DateTime fechaSeleccionada = DateTime.now();
    
    // Variables para las imágenes
    File? imagen1;
    File? imagen2;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              // Permitir que ocupe hasta el 90% de la pantalla
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nuevo Seguimiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),
                  
                  // Formulario scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fecha del seguimiento
                          Text(
                            'Fecha:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: fechaSeleccionada,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Color(0xFF4CAF50),
                                        onPrimary: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  fechaSeleccionada = DateTime(
                                    picked.year,
                                    picked.month,
                                    picked.day,
                                    fechaSeleccionada.hour,
                                    fechaSeleccionada.minute,
                                  );
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(fechaSeleccionada),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Motivo
                          Text(
                            'Motivo:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: motivoController,
                            decoration: InputDecoration(
                              hintText: 'Ingrese el motivo del seguimiento',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: 16),
                          
                          // Observaciones
                          Text(
                            'Observaciones:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: observacionesController,
                            decoration: InputDecoration(
                              hintText: 'Ingrese las observaciones del cultivo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            maxLines: 4,
                          ),
                          SizedBox(height: 16),
                          
                          // Notas adicionales
                          Text(
                            'Notas adicionales (opcional):',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: notasController,
                            decoration: InputDecoration(
                              hintText: 'Ingrese notas adicionales',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 24),
                          
                          // Fotografías
                          Text(
                            'Fotografías (opcional - máximo 2):',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 12),
                          
                          // Contenedor para las imágenes
                          Row(
                            children: [
                              // Primera imagen
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    await _mostrarOpcionesFoto(context, (File file) {
                                      setState(() {
                                        imagen1 = file;
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF1F8E9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Color(0xFFDCEDC8)),
                                    ),
                                    child: imagen1 != null
                                        ? Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  imagen1!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      imagen1 = null;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.8),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                color: Color(0xFF4CAF50),
                                                size: 36,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Imagen 1',
                                                style: TextStyle(
                                                  color: Color(0xFF4CAF50),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              // Segunda imagen
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    await _mostrarOpcionesFoto(context, (File file) {
                                      setState(() {
                                        imagen2 = file;
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF1F8E9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Color(0xFFDCEDC8)),
                                    ),
                                    child: imagen2 != null
                                        ? Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  imagen2!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      imagen2 = null;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.8),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_a_photo,
                                                color: Color(0xFF4CAF50),
                                                size: 36,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Imagen 2',
                                                style: TextStyle(
                                                  color: Color(0xFF4CAF50),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Botones de acción
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text('Cancelar'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Validar y guardar
                          if (motivoController.text.trim().isEmpty || 
                              observacionesController.text.trim().isEmpty) {
                            // Mostrar error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('El motivo y las observaciones son obligatorios'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          // Cerrar el modal para mostrar carga
                          Navigator.pop(context);
                          
                          // Guardar seguimiento
                          _guardarSeguimiento(
                            motivoController.text.trim(),
                            observacionesController.text.trim(),
                            notasController.text.trim(),
                            fechaSeleccionada,
                            imagen1,
                            imagen2,
                          );
                        },
                        icon: Icon(Icons.save),
                        label: Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Mostrar opciones para tomar foto o seleccionar de galería
  Future _mostrarOpcionesFoto(BuildContext context, Function(File) onImageSelected) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Opción de cámara
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? imagen = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                        imageQuality: 70,
                      );
                      if (imagen != null) {
                        onImageSelected(File(imagen.path));
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Color(0xFF4CAF50),
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Cámara'),
                      ],
                    ),
                  ),
                  
                  // Opción de galería
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? imagen = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (imagen != null) {
                        onImageSelected(File(imagen.path));
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Color(0xFF4CAF50),
                            size: 32,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Galería'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para guardar seguimiento
  Future<void> _guardarSeguimiento(
    String motivo,
    String observaciones,
    String notas,
    DateTime fecha,
    File? imagen1,
    File? imagen2,
  ) async {
    // Mostrar diálogo de carga
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
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 25,
            ),
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
                        "Guardando seguimiento",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Por favor, espere...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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

    try {
      setState(() {
        _isLoading = true;
      });

      // Variable para almacenar URLs de imágenes
      String? imagenUrl1;
      String? imagenUrl2;
      
      // Subir la primera imagen si existe
      if (imagen1 != null) {
        String fileName1 = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagen1.path)}';
        Reference ref1 = _storage.ref().child('seguimiento_images').child(fileName1);
        
        await ref1.putFile(imagen1);
        imagenUrl1 = await ref1.getDownloadURL();
      }
      
      // Subir la segunda imagen si existe
      if (imagen2 != null) {
        String fileName2 = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagen2.path)}';
        Reference ref2 = _storage.ref().child('seguimiento_images').child(fileName2);
        
        await ref2.putFile(imagen2);
        imagenUrl2 = await ref2.getDownloadURL();
      }
      
      // Crear documento de seguimiento
      await _firestore.collection('Seguimiento').add({
        'fkid_cultivo': widget.cultivoId,
        'motivo': motivo,
        'observaciones': observaciones,
        'notas': notas.isNotEmpty ? notas : null,
        'imagen': imagenUrl1,
        'imagen_2': imagenUrl2,
        'fecha_creacion': Timestamp.fromDate(fecha),
      });
      
      setState(() {
        _isLoading = false;
      });
      
      // Cerrar el diálogo de carga
      Navigator.of(context).pop();
      
      // Mostrar mensaje de éxito
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
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seguimiento guardado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'El seguimiento ha sido registrado correctamente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Color(0xFF43A047),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      // Mostrar mensaje de error
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
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error al guardar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No se pudo guardar el seguimiento',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      );
    }
  }

  // Método para confirmar eliminación de seguimiento
  void _confirmarEliminacion(BuildContext context, String seguimientoId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Confirmar eliminación',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever, color: Colors.red, size: 48),
              ),
              SizedBox(height: 16),
              Text(
                '¿Estás seguro de que deseas eliminar este registro de seguimiento?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFFFECB3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer y todos los datos relacionados se perderán.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cerrar el diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.delete_outline),
              label: Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // Cerrar el diálogo de confirmación
                Navigator.of(dialogContext).pop();
                
                // Eliminar el seguimiento
                await _eliminarSeguimiento(seguimientoId);
              },
            ),
          ],
        );
      },
    );
  }

  // Método para eliminar seguimiento
  Future<void> _eliminarSeguimiento(String seguimientoId) async {
    // Mostrar diálogo de carga
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
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 25,
            ),
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
                        "Eliminando seguimiento",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Por favor, espere...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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

    try {
      // Obtener primero los datos del seguimiento para eliminar imágenes si existen
      DocumentSnapshot seguimientoDoc = await _firestore
          .collection('Seguimiento')
          .doc(seguimientoId)
          .get();
      
      if (seguimientoDoc.exists) {
        Map<String, dynamic> data = seguimientoDoc.data() as Map<String, dynamic>;
        
        // Eliminar la imagen 1 si existe
        if (data.containsKey('imagen') && data['imagen'] != null) {
          try {
            // Extraer la ruta del storage desde la URL
            Reference ref = _storage.refFromURL(data['imagen']);
            await ref.delete();
          } catch (e) {
            print('Error al eliminar imagen 1: $e');
          }
        }
        
        // Eliminar la imagen 2 si existe
        if (data.containsKey('imagen_2') && data['imagen_2'] != null) {
          try {
            // Extraer la ruta del storage desde la URL
            Reference ref = _storage.refFromURL(data['imagen_2']);
            await ref.delete();
          } catch (e) {
            print('Error al eliminar imagen 2: $e');
          }
        }
      }
      
      // Eliminar el documento de seguimiento
      await _firestore.collection('Seguimiento').doc(seguimientoId).delete();
      
      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      // Mostrar mensaje de éxito
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
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seguimiento eliminado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'El registro ha sido eliminado correctamente',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Color(0xFF43A047),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      );
    } catch (e) {
      // Cerrar diálogo de carga
      Navigator.of(context).pop();
      
      // Mostrar mensaje de error
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
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error al eliminar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No se pudo eliminar el seguimiento',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      );
    }
  }

  // BottomNavigationBar (igual al de CultivosScreen)
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey[600],
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      currentIndex: 2, // El índice de la pestaña actual (Cultivos)
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Mercado',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.spa_outlined),
          activeIcon: Icon(Icons.spa),
          label: 'Cultivos',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          activeIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}