import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/CultivosScreen.dart';
import 'package:flutter_application_1/HomeScreenApp.dart';
import 'package:flutter_application_1/IAChatScreen.dart';
import 'package:flutter_application_1/UserProfileScreen.dart';
import 'RecordatoriosListScreen.dart';

class AgregarRecordatorioScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final String uid;

  const AgregarRecordatorioScreen({
    Key? key,
    this.selectedDate,
    required this.uid,
    required String recordatorioId,
  }) : super(key: key);

  @override
  State<AgregarRecordatorioScreen> createState() =>
      _AgregarRecordatorioScreenState();
}

class _AgregarRecordatorioScreenState extends State<AgregarRecordatorioScreen> {
  final _tituloController = TextEditingController();
  final _notasController = TextEditingController();
  final _categoriaController = TextEditingController();
  String _hora = '25'; // Valor por defecto
  String _repetir = '';
  bool _isLoading = false;

  // Formatear la fecha para mostrarla
  String _getFormattedDate(DateTime date) {
    const months = [
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
    return 'Día ${date.day} de ${months[date.month - 1]} del ${date.year}';
  }

  // Función para guardar el recordatorio en la colección Alerta
  Future<void> _guardarRecordatorio() async {
    if (_tituloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un título')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final displayDate = widget.selectedDate ?? DateTime.now();

      // Guardar el recordatorio en la colección 'Alerta' en Firestore
      await FirebaseFirestore.instance.collection('Alerta').add({
        'titulo': _tituloController.text,
        'fecha_hora': Timestamp.fromDate(displayDate),
        'categoria':
            _categoriaController.text.isEmpty
                ? 'recordatorio'
                : _categoriaController.text,
        'notas': _notasController.text,
        'repetir': _repetir,
        'fkid_cultivo': '',
        'fkid_usuario': widget.uid,
        'estado': 'pendiente',
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recordatorio guardado para ${_getFormattedDate(displayDate)}',
          ),
          backgroundColor: const Color(0xFF6BC4B1),
        ),
      );

      // Navegar a la lista de recordatorios
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecordatoriosListScreen(uid: widget.uid),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si no se proporciona una fecha, usar la fecha actual
    final displayDate = widget.selectedDate ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF6BC4B1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const Text(
                      'Agregar\nRecordatorio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getFormattedDate(
                        displayDate,
                      ), // Usar la fecha seleccionada
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Form con scroll para evitar overflow
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _tituloController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Text(
                              'Hora:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTimeOption('1', '25'),
                                  _buildTimeOption('2', '30'),
                                  _buildTimeOption('3', '35'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _categoriaController,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _notasController,
                          decoration: const InputDecoration(
                            labelText: 'Notas',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2, // Reducido de 3 a 2 para ahorrar espacio
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Repetir',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _repetir = value,
                        ),
                        const SizedBox(
                          height: 30,
                        ), // Aumentado para dar espacio
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _guardarRecordatorio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6BC4B1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'Finalizar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                        const SizedBox(
                          height: 90,
                        ), // Añadido para barra de navegación
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildTimeOption(String label, String value) {
    final isSelected = _hora == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _hora = value;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18, // Reducido de 20 a 18
            backgroundColor:
                isSelected ? const Color(0xFF6BC4B1) : Colors.grey[300],
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
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
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Notificaciones está activo
        onTap: (index) {
          // Navegar según el índice seleccionado
          switch (index) {
            case 0: // Home
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreenApp(uid: widget.uid),
                ),
              );
              break;
            case 1: // Cultivos
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CultivosScreen(uid: widget.uid),
                ),
              );
              break;
            case 2: // IA Chat
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IAChatScreen()),
              );
              break;
            case 3: // Notificaciones
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RecordatoriosListScreen(uid: widget.uid),
                ),
              );
              break;
            case 4: // Perfil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(uid: widget.uid),
                ),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa_outlined),
            activeIcon: Icon(Icons.spa),
            label: 'Cultivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Asistente',
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
}
