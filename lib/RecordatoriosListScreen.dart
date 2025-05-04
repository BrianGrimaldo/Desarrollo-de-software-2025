import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/CultivosScreen.dart';
import 'package:flutter_application_1/HomeScreenApp.dart';
import 'package:flutter_application_1/IAChatScreen.dart';
import 'package:flutter_application_1/UserProfileScreen.dart';
import 'AgregarRecordatorioScreen.dart'; // Asegúrate de importar esta pantalla

class Recordatorio {
  final String id;
  final String titulo;
  final DateTime fechaHora;
  final String categoria;
  final String notas;
  final String repetir;
  final String estado;

  Recordatorio({
    required this.id,
    required this.titulo,
    required this.fechaHora,
    required this.categoria,
    required this.notas,
    required this.repetir,
    required this.estado,
  });

  // Convertir un documento de Firestore a un objeto Recordatorio
  factory Recordatorio.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recordatorio(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      fechaHora: (data['fecha_hora'] as Timestamp).toDate(),
      categoria: data['categoria'] ?? '',
      notas: data['notas'] ?? '',
      repetir: data['repetir'] ?? '',
      estado: data['estado'] ?? 'pendiente',
    );
  }
}

class RecordatoriosListScreen extends StatefulWidget {
  final String uid;

  const RecordatoriosListScreen({Key? key, required this.uid})
    : super(key: key);

  @override
  State<RecordatoriosListScreen> createState() =>
      _RecordatoriosListScreenState();
}

class _RecordatoriosListScreenState extends State<RecordatoriosListScreen> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
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
                      'Recordatorios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tus tareas programadas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Filtros
            Container(
              margin: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Todos'),
                    const SizedBox(width: 10),
                    _buildFilterChip('Pendientes'),
                    const SizedBox(width: 10),
                    _buildFilterChip('Completados'),
                    const SizedBox(width: 10),
                    _buildFilterChip('Próximos'),
                  ],
                ),
              ),
            ),
            // Lista de recordatorios
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getRecordatoriosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  final recordatorios =
                      snapshot.data!.docs
                          .map((doc) => Recordatorio.fromFirestore(doc))
                          .toList();

                  // ORDENAR EN MEMORIA - IMPORTANTE PARA EVITAR ERROR DE ÍNDICE
                  recordatorios.sort(
                    (a, b) => a.fechaHora.compareTo(b.fechaHora),
                  );

                  // Filtrar recordatorios
                  final filteredRecordatorios = _filterRecordatorios(
                    recordatorios,
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 80,
                    ), // Espacio para el FAB
                    itemCount: filteredRecordatorios.length,
                    itemBuilder: (context, index) {
                      return _buildRecordatorioCard(
                        filteredRecordatorios[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar a la pantalla de agregar recordatorio
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AgregarRecordatorioScreen(
                    selectedDate: DateTime.now(), // Usar fecha actual
                    uid: widget.uid,
                    recordatorioId: '',
                  ),
            ),
          );
        },
        backgroundColor: const Color(0xFF6BC4B1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Agregar Recordatorio',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Stream para obtener recordatorios de la colección 'Alerta'
  // MODIFICADO: Eliminar .orderBy para evitar el error de índice
  Stream<QuerySnapshot> _getRecordatoriosStream() {
    return FirebaseFirestore.instance
        .collection('Alerta')
        .where('fkid_usuario', isEqualTo: widget.uid)
        // ELIMINADO: .orderBy('fecha_hora', descending: false)
        .snapshots();
  }

  List<Recordatorio> _filterRecordatorios(List<Recordatorio> recordatorios) {
    switch (_selectedFilter) {
      case 'Pendientes':
        return recordatorios.where((r) => r.estado == 'pendiente').toList();
      case 'Completados':
        return recordatorios.where((r) => r.estado == 'completado').toList();
      case 'Próximos':
        final now = DateTime.now();
        return recordatorios.where((r) => r.fechaHora.isAfter(now)).toList();
      default:
        return recordatorios;
    }
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6BC4B1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6BC4B1) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordatorioCard(Recordatorio recordatorio) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recordatorio.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Chip(
                  label: Text(
                    recordatorio.estado,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(recordatorio.estado),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatDate(recordatorio.fechaHora),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatTime(recordatorio.fechaHora),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (recordatorio.notas.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                recordatorio.notas,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF6BC4B1)),
                  onPressed: () {
                    // Navegar a editar recordatorio
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AgregarRecordatorioScreen(
                              selectedDate: recordatorio.fechaHora,
                              uid: widget.uid,
                              recordatorioId: recordatorio.id,
                            ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    recordatorio.estado == 'pendiente'
                        ? Icons.check_circle_outline
                        : Icons.restore,
                    color: Colors.green,
                  ),
                  onPressed: () => _toggleRecordatorioStatus(recordatorio),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteRecordatorio(recordatorio.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6BC4B1).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.alarm, size: 64, color: Color(0xFF6BC4B1)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay recordatorios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega nuevos recordatorios para tus tareas',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange.withOpacity(0.2);
      case 'completado':
        return Colors.green.withOpacity(0.2);
      case 'cancelado':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Future<void> _toggleRecordatorioStatus(Recordatorio recordatorio) async {
    final newStatus =
        recordatorio.estado == 'pendiente' ? 'completado' : 'pendiente';

    await FirebaseFirestore.instance
        .collection('Alerta')
        .doc(recordatorio.id)
        .update({'estado': newStatus});
  }

  Future<void> _deleteRecordatorio(String id) async {
    await FirebaseFirestore.instance.collection('Alerta').doc(id).delete();
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4CAF50),
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
            case 3: // Notificaciones (Ya estamos aquí)
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
