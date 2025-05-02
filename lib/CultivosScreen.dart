import 'package:flutter/material.dart';
import 'DetalleCultivoScreen.dart';
import 'RegisterCultivoScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LogginScreen.dart';
import 'package:flutter/services.dart';

class CultivosScreen extends StatefulWidget {
  final String uid;

  const CultivosScreen({super.key, required this.uid});

  @override
  _CultivosScreenState createState() => _CultivosScreenState();
}

class _CultivosScreenState extends State<CultivosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  bool _isSearching = false;

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
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeaderStats(),
          Expanded(child: _buildCultivosListView()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterCultivoScreen(uid: widget.uid),
            ),
          );
        },
        backgroundColor: Color(0xFF4CAF50),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // AppBar mejorado con campo de búsqueda
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFF4CAF50),
      title:
          _isSearching
              ? TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar cultivo...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
              : Row(
                children: [
                  Icon(Icons.spa, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Mis Cultivos',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
      actions: [
        _isSearching
            ? IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              },
            )
            : IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        if (!_isSearching)
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Mostrar opciones de filtrado
              _showFilterOptions(context);
            },
          ),
        if (!_isSearching)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              // Manejo de opciones del menú (ya no incluye logout)
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Ayuda'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Color(0xFF4CAF50)),
                      SizedBox(width: 8),
                      Text('Configuración'),
                    ],
                  ),
                ),
              ];
            },
          ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }

  // Widget para mostrar estadísticas de los cultivos
  Widget _buildHeaderStats() {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collection('Cultivo')
                .where('fkid_usuario', isEqualTo: widget.uid)
                .snapshots(),
        builder: (context, snapshot) {
          int totalCultivos = 0;
          int cultivosConAlerta = 0;

          if (snapshot.hasData) {
            totalCultivos = snapshot.data!.docs.length;

            for (var doc in snapshot.data!.docs) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (data.containsKey('alertStatus') &&
                  data['alertStatus'] != 'Normal') {
                cultivosConAlerta++;
              }
            }
          }

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Cultivos',
                  totalCultivos.toString(),
                  Icons.grass,
                  Color(0xFF4CAF50),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Alertas Activas',
                  cultivosConAlerta.toString(),
                  Icons.warning_amber,
                  cultivosConAlerta > 0 ? Colors.amber : Colors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Tarjeta de estadísticas - CORREGIDA para evitar overflow
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12), // Reducido de 16 a 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ajustar al contenido
        children: [
          Container(
            padding: EdgeInsets.all(8), // Reducido de 10 a 8
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22), // Reducido de 24 a 22
          ),
          SizedBox(width: 8), // Reducido de 12 a 8
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18, // Reducido de 20 a 18
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  overflow:
                      TextOverflow.ellipsis, // Permitir elipsis si no cabe
                ),
                SizedBox(height: 2), // Reducido de 4 a 2
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow:
                      TextOverflow.ellipsis, // Permitir elipsis si no cabe
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lista mejorada de cultivos
  Widget _buildCultivosListView() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('Cultivo')
              .where('fkid_usuario', isEqualTo: widget.uid)
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
                  'Error al cargar los cultivos',
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
                    Icons.agriculture,
                    color: Color(0xFF4CAF50),
                    size: 60,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'No hay cultivos registrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Toca el botón + para añadir un nuevo cultivo',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RegisterCultivoScreen(uid: widget.uid),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Nuevo Cultivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Filtrar cultivos según la búsqueda
        var cultivos = snapshot.data!.docs;

        if (_searchQuery.isNotEmpty) {
          cultivos =
              cultivos.where((cultivo) {
                Map<String, dynamic> data =
                    cultivo.data() as Map<String, dynamic>;
                String nombre = data['nombre'] ?? '';
                return nombre.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
              }).toList();
        }

        if (cultivos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, color: Colors.grey, size: 60),
                SizedBox(height: 16),
                Text(
                  'No se encontraron cultivos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Intenta con otra búsqueda',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            itemCount: cultivos.length,
            padding: EdgeInsets.only(top: 8, bottom: 80), // Espacio para el FAB
            itemBuilder: (context, index) {
              var cultivo = cultivos[index];
              Map<String, dynamic> cultivoData =
                  cultivo.data() as Map<String, dynamic>;

              String estado = 'Normal';
              int dias = 0;
              String imagenUrl = '';

              if (cultivoData.containsKey('alertStatus')) {
                estado = cultivoData['alertStatus'];
              }

              if (cultivoData.containsKey('daysTranscurridos')) {
                dias =
                    cultivoData['daysTranscurridos'] is int
                        ? cultivoData['daysTranscurridos']
                        : 0;
              }

              if (cultivoData.containsKey('imagen')) {
                imagenUrl = cultivoData['imagen'];
              }

              // Determinar el color del estado
              Color statusColor;
              IconData statusIcon;

              switch (estado.toLowerCase()) {
                case 'alerta':
                  statusColor = Colors.orange;
                  statusIcon = Icons.warning_amber_rounded;
                  break;
                case 'crítico':
                case 'critico':
                  statusColor = Colors.red;
                  statusIcon = Icons.error;
                  break;
                default:
                  statusColor = Color(0xFF4CAF50);
                  statusIcon = Icons.check_circle;
              }

              return _buildCultivoCard(
                cultivoId: cultivo.id,
                nombre: cultivoData['nombre'] ?? 'Sin nombre',
                descripcion: cultivoData['descripcion'] ?? 'Sin descripción',
                estado: estado,
                dias: dias,
                statusColor: statusColor,
                statusIcon: statusIcon,
                imageUrl: imagenUrl,
              );
            },
          ),
        );
      },
    );
  }

  // Tarjeta de cultivo mejorada
  Widget _buildCultivoCard({
    required String cultivoId,
    required String nombre,
    required String descripcion,
    required String estado,
    required int dias,
    required Color statusColor,
    required IconData statusIcon,
    String imageUrl = '',
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleCultivoScreen(cultivoId: cultivoId),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Barra superior con estado
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Estado: $estado',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '$dias días',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icono o imagen
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        imageUrl.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.grass,
                                    color: Color(0xFF4CAF50),
                                    size: 30,
                                  );
                                },
                              ),
                            )
                            : Icon(
                              Icons.grass,
                              color: Color(0xFF4CAF50),
                              size: 30,
                            ),
                  ),

                  SizedBox(width: 16),

                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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

            // Botones de acción
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  DetalleCultivoScreen(cultivoId: cultivoId),
                        ),
                      );
                    },
                    icon: Icon(Icons.visibility, size: 18),
                    label: Text('Ver detalles'),
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF4CAF50),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BottomNavigationBar mejorado
  Widget _buildBottomNavigationBar() {
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
      ),
    );
  }

  // Diálogo para mostrar opciones de filtrado
  void _showFilterOptions(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrar Cultivos',
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
              _buildFilterOption(
                Icons.check_circle,
                'Estado Normal',
                Colors.green,
              ),
              _buildFilterOption(
                Icons.warning_amber_rounded,
                'Con Alertas',
                Colors.orange,
              ),
              _buildFilterOption(Icons.error, 'Estado Crítico', Colors.red),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Aplicar filtros
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Aplicar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Opción de filtro
  Widget _buildFilterOption(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Checkbox(
        value: false,
        onChanged: (value) {},
        activeColor: Color(0xFF4CAF50),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
