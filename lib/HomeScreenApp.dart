import 'package:flutter/material.dart';
import 'package:flutter_application_1/CultivosScreen.dart';
import 'package:flutter_application_1/ManageNotificationsScreen.dart';
import 'package:flutter_application_1/IAChatScreen.dart'; // <--- Importa tu pantalla de IA

void main() {
  runApp(HomeScreenApp());
}

class HomeScreenApp extends StatelessWidget {
  const HomeScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.green, textTheme: TextTheme()),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  MaterialPageRoute(builder: (context) => HomeScreenApp()),
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
                  MaterialPageRoute(builder: (context) => CultivosScreen()),
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
}
