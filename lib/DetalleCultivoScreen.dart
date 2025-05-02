import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/EditarCultivoScreen.dart';
import 'package:flutter/services.dart';
import 'SeguimientoCultivoScreen.dart';

class DetalleCultivoScreen extends StatelessWidget {
  final String cultivoId;

  const DetalleCultivoScreen({super.key, required this.cultivoId});

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
      backgroundColor: Color(
        0xFFF7F9F4,
      ), // Fondo crema claro para temática agrícola
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF4CAF50), // Verde agricultura
        title: Row(
          children: [
            Icon(Icons.eco, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Detalle del Cultivo',
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
                builder:
                    (context) => AlertDialog(
                      title: Text('Ayuda'),
                      content: Text(
                        'Esta pantalla muestra los detalles del cultivo. Puedes editar o eliminar este cultivo usando los botones en la parte inferior.',
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
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('Cultivo')
                .doc(cultivoId)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFF388E3C), // Verde más oscuro
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
                    'Error al cargar el cultivo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.not_interested, color: Colors.amber, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'No se encontró el cultivo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          // Obtener los datos del cultivo
          Map<String, dynamic> cultivo =
              snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de estado del cultivo
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFF388E3C),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.spa, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Cultivo Activo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tarjeta principal con información del cultivo
                Card(
                  margin: EdgeInsets.all(16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título y precio
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.grass,
                                color: Color(0xFF388E3C),
                                size: 40,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cultivo['nombre'] ?? 'Sin nombre',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  if (cultivo['precio'] != null)
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Color(0xFF81C784),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        '\$${cultivo['precio']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.share, color: Color(0xFF4CAF50)),
                              onPressed: () {
                                // Compartir cultivo
                              },
                            ),
                          ],
                        ),

                        Divider(
                          height: 32,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),

                        // Granja / Usuario
                        if (cultivo['fkid_usuario'] != null)
                          FutureBuilder<DocumentSnapshot>(
                            future:
                                FirebaseFirestore.instance
                                    .collection('Usuario')
                                    .doc(cultivo['fkid_usuario'])
                                    .get(),
                            builder: (context, userSnapshot) {
                              String farmName = "Granja";
                              String location = "";

                              if (userSnapshot.hasData &&
                                  userSnapshot.data!.exists) {
                                var userData =
                                    userSnapshot.data!.data()
                                        as Map<String, dynamic>;
                                farmName = userData['nombre'] ?? "Granja";
                                location = userData['ubicacion'] ?? "";
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Color(0xFF4CAF50),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            farmName,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                          if (location.isNotEmpty)
                                            Text(
                                              location,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        // Descripción
                        if (cultivo['descripcion'] != null) ...[
                          _buildSectionTitle('Descripción', Icons.description),
                          Container(
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
                              cultivo['descripcion'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF212121),
                                height: 1.4,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],

                        // Observaciones
                        if (cultivo['observaciones'] != null) ...[
                          _buildSectionTitle(
                            'Observaciones',
                            Icons.note_alt_outlined,
                          ),
                          Container(
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
                              cultivo['observaciones'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF212121),
                                height: 1.4,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],

                        // Notas
                        if (cultivo['notas'] != null) ...[
                          _buildSectionTitle(
                            'Notas',
                            Icons.sticky_note_2_outlined,
                          ),
                          Container(
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
                              cultivo['notas'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF212121),
                                height: 1.4,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
                ),

                // Tarjeta de información adicional
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (cultivo['fecha_creacion'] != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Fecha de creación:',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                _formatDate(cultivo['fecha_creacion']),
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Botones de acción
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Botones originales (Editar y Eliminar)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.edit),
                              label: Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => EditarCultivoScreen(
                                          cultivoId: cultivoId,
                                          uid: cultivo['fkid_usuario'],
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.delete),
                              label: Text('Eliminar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                _mostrarDialogoConfirmacion(context, cultivoId);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Nuevo botón para gestionar seguimiento
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.trending_up),
                          label: Text('Gestionar Seguimiento'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SeguimientoCultivoScreen(
                                      cultivoId: cultivoId,
                                      cultivoNombre:
                                          cultivo['nombre'] ?? 'Sin nombre',
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
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
      ),
    );
  }

  // Widget para crear un título de sección con icono
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4CAF50)),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  // Método para formatear la fecha
  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();

    // Lista de nombres de meses en español
    List<String> meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${dateTime.day} de ${meses[dateTime.month - 1]} de ${dateTime.year}';
  }

  // Método para mostrar diálogo de confirmación al borrar
  void _mostrarDialogoConfirmacion(BuildContext context, String cultivoId) {
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
                '¿Estás seguro de que deseas eliminar este cultivo?',
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

                // Mostrar un diálogo de carga con animación
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
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
                                    "Eliminando cultivo",
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
                  // Simular un pequeño retraso para mostrar la animación de carga
                  await Future.delayed(Duration(milliseconds: 1000));

                  // Eliminar el cultivo
                  await FirebaseFirestore.instance
                      .collection('Cultivo')
                      .doc(cultivoId)
                      .delete();

                  // Cerrar diálogo de carga
                  Navigator.of(context).pop();

                  // Mostrar mensaje de éxito con un SnackBar mejorado
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
                                    'Cultivo eliminado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'El cultivo ha sido eliminado correctamente',
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
                      action: SnackBarAction(
                        label: 'ACEPTAR',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );

                  // Regresar a la pantalla anterior con una animación de desvanecimiento
                  Navigator.of(context).pop();
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
                                    'No se pudo eliminar el cultivo',
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
                      action: SnackBarAction(
                        label: 'DETALLES',
                        textColor: Colors.white,
                        onPressed: () {
                          // Mostrar diálogo con detalles completos del error
                          showDialog(
                            context: context,
                            builder: (BuildContext errorContext) {
                              return AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Detalles del error'),
                                  ],
                                ),
                                content: Text('$e'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(errorContext).pop();
                                    },
                                    child: Text('Cerrar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Opción para reintentar
                                      Navigator.of(errorContext).pop();
                                      _mostrarDialogoConfirmacion(
                                        context,
                                        cultivoId,
                                      );
                                    },
                                    child: Text('Reintentar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
