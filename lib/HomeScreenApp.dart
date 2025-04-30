import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/CultivosScreen.dart';
import 'package:flutter_application_1/ManageNotificationsScreen.dart';
import 'package:flutter_application_1/IAChatScreen.dart'; // <--- Importa tu pantalla de IA
import 'package:firebase_core/firebase_core.dart';
 // Asegúrate de importar CultivosScreen

class HomeScreenApp extends StatelessWidget {
  final String uid; // Recibimos el UID del usuario

  // Constructor para recibir el UID del usuario
  const HomeScreenApp({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, $uid'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: Image.asset(
                'assets/organic_farming.jpg',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Best Organic Agriculture Firms',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Give lady of they such they sure it. Me contained explained my education. '
                    'Vulgar as hearts by garnet, perceived determine departure explained no forfeited he something an. '
                    'Contrasted dissimilar get joy you instrument out reasonably.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 25,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Discover More'),
                  ),
                  SizedBox(height: 30),
                  _buildSection(
                    title: 'Sustainable Agricultural Practices',
                    content:
                        'Sustainable farming practices are essential for preserving the environment '
                        'while still providing for the global population. Practices such as crop rotation, organic '
                        'fertilizers, and agroforestry are all examples of ways to maintain long-term productivity '
                        'without depleting resources. By adopting such practices, farmers can improve soil health, '
                        'conserve water, and reduce greenhouse gas emissions.',
                    imagePath: 'assets/sustainable_farming.jpg',
                  ),
                  SizedBox(height: 30),
                  _buildSection(
                    title: 'Organic Farming Benefits',
                    content:
                        'Organic farming avoids synthetic fertilizers and pesticides, focusing instead on '
                        'sustainable methods such as composting, crop rotation, and the use of natural predators to control pests. '
                        'This not only helps the environment but also results in healthier produce, free from harmful chemicals. '
                        'Additionally, organic farming promotes biodiversity, improves soil health, and supports local ecosystems.',
                    imagePath: 'assets/organic_farming_2.jpg',
                  ),
                  SizedBox(height: 30),
                  // Aquí agregamos la consulta a los cultivos del usuario logueado
                  _buildUserCultivosSection(uid),
                ],
              ),
            ),
          ],
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
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreenApp(uid: uid)),
                );
              },
              child: Icon(Icons.home, color: Colors.green),
            ),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CultivosScreen(uid: uid)), // Pasamos el uid
                );
              },
              child: Icon(Icons.access_time, color: Colors.green),
            ),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IAChatScreen()),
                );
              },
              child: Icon(Icons.nature, color: Colors.green),
            ),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageNotificationsScreen(),
                  ),
                );
              },
              child: Stack(
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
            ),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required String imagePath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(content, style: TextStyle(fontSize: 16, color: Colors.black54)),
        SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  // Método para construir la sección de cultivos del usuario
  Widget _buildUserCultivosSection(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Cultivo')
          .where('fkid_usuario', isEqualTo: uid) // Filtramos los cultivos por el UID del usuario
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar los cultivos'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No tienes cultivos registrados.'));
        }

        var cultivos = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            cultivos.length,
            (index) {
              var cultivo = cultivos[index];
              return ListTile(
                title: Text(cultivo['nombre']),
                subtitle: Text(cultivo['descripcion']),
              );
            },
          ),
        );
      },
    );
  }
}
