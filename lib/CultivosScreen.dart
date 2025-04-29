import 'package:flutter/material.dart';
import 'DetalleCultivoScreen.dart'; // Importa el detalle

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: CultivosScreen()),
  );
}

class CultivosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cultivos activos'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
          IconButton(icon: Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar cultivo...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1),
              CultivoCard(
                cultivoName: 'Maíz',
                alertStatus: 'SIN ALERTAS',
                daysTranscurridos: 48,
                statusColor: Colors.green,
              ),
              CultivoCard(
                cultivoName: 'Naranja',
                alertStatus: 'NORMAL',
                daysTranscurridos: 48,
                statusColor: Colors.orange,
              ),
              CultivoCard(
                cultivoName: 'Cultivo 1',
                alertStatus: '',
                daysTranscurridos: 48,
                statusColor: Colors.transparent,
              ),
              CultivoCard(
                cultivoName: 'Cultivo 2',
                alertStatus: '',
                daysTranscurridos: 48,
                statusColor: Colors.transparent,
              ),
            ],
          ),
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

  CultivoCard({
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
