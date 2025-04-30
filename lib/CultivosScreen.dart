import 'package:flutter/material.dart';
import 'DetalleCultivoScreen.dart'; // Importa el detalle
import 'RegisterCultivoScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LogginScreen.dart';

class CultivosScreen extends StatefulWidget {
  final String uid; // Recibimos el UID del usuario

  // Constructor para recibir el UID del usuario
  const CultivosScreen({super.key, required this.uid});

  @override
  _CultivosScreenState createState() => _CultivosScreenState();
}

class _CultivosScreenState extends State<CultivosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cultivos activos'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.add), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterCultivoScreen(uid: widget.uid),  // Pasamos el uid
              ),
            );
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Cultivo')
              .where('fkid_usuario', isEqualTo: widget.uid) // Filtramos por el UID del usuario
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error al cargar los cultivos'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No hay cultivos registrados.'));
            }

            var cultivos = snapshot.data!.docs;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  cultivos.length,
                  (index) {
                    var cultivo = cultivos[index];
                    return CultivoCard(
                      cultivoName: cultivo['nombre'],
                      alertStatus: cultivo['alertStatus'] ?? '',
                      daysTranscurridos: cultivo['daysTranscurridos'] ?? 0,
                      statusColor: Colors.green, // Puedes hacer esto dinámico según el estado
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green[400],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.green),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time, color: Colors.green),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.nature, color: Colors.green),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      '4',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
        ],
      ),
    );
  }
}

class CultivoCard extends StatelessWidget {
  final String cultivoName;
  final String alertStatus;
  final int daysTranscurridos;
  final Color statusColor;

  const CultivoCard({super.key, 
    required this.cultivoName,
    required this.alertStatus,
    required this.daysTranscurridos,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.eco, color: Colors.green, size: 40),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cultivoName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.notifications, color: statusColor, size: 20),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          alertStatus,
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Días: $daysTranscurridos',
                  style: TextStyle(fontSize: 14),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleCultivoScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(50, 25),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Ver detalle',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
