import 'package:flutter/material.dart';

void main() {
  runApp(HomeScreenApp());
}

class HomeScreenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Image section - Se reduce el tamaño de la imagen
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
            ),
            child: Image.asset(
              'assets/organic_farming.jpg', // Asegúrate de tener la imagen en la ruta correcta
              fit: BoxFit.cover,
              height:
                  MediaQuery.of(context).size.height *
                  0.3, // Imagen ocupando el 30% de la pantalla
              width: double.infinity,
            ),
          ),
          // Título y texto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Organic Agriculture Firms',
                  style: TextStyle(
                    fontSize: 28, // Aumenté el tamaño de la fuente
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Give lady of they such they sure it. Me contained explained my education. Vulgar as hearts by garnet, perceived determine departure explained no forfeited he something an. Contrasted dissimilar get joy you instrument out reasonably.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Discover More'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Sección adicional de texto sobre agricultura sostenible
                Text(
                  'Sustainable Agricultural Practices',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sustainable farming practices are essential for preserving the environment while still providing for the global population. Practices such as crop rotation, organic fertilizers, and agroforestry are all examples of ways to maintain long-term productivity without depleting resources. By adopting such practices, farmers can improve soil health, conserve water, and reduce greenhouse gas emissions.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 20),
                // Imagen que ilustra prácticas agrícolas sostenibles
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/sustainable_farming.jpg', // Imagen adicional sobre agricultura sostenible
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: 30),
                // Otra sección adicional sobre agricultura orgánica
                Text(
                  'Organic Farming Benefits',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Organic farming avoids synthetic fertilizers and pesticides, focusing instead on sustainable methods such as composting, crop rotation, and the use of natural predators to control pests. This not only helps the environment but also results in healthier produce, free from harmful chemicals. Additionally, organic farming promotes biodiversity, improves soil health, and supports local ecosystems.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 20),
                // Imagen que ilustra la agricultura orgánica
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/organic_farming_2.jpg', // Imagen adicional sobre agricultura orgánica
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.green[400],
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home), // Ícono de inicio
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time), // Ícono de reloj
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.nature), // Ícono de naturaleza (hoja)
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications), // Ícono de notificaciones
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
            BottomNavigationBarItem(
              icon: Icon(Icons.group), // Ícono de grupo
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
