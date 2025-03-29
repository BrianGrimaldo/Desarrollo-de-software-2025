import 'package:flutter/material.dart';

class ManageNotificationsScreen extends StatefulWidget {
  @override
  _ManageNotificationsScreenState createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  bool _cropNotifications = true;
  bool _inputNotifications = true;
  bool _weatherNotifications = true;
  bool _taskCalendarNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Notificaciones'),
        backgroundColor: Colors.greenAccent.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Notificaciones de Cultivos'),
              value: _cropNotifications,
              onChanged: (bool value) {
                setState(() {
                  _cropNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Notificaciones de Insumos'),
              value: _inputNotifications,
              onChanged: (bool value) {
                setState(() {
                  _inputNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Notificaciones de Clima'),
              value: _weatherNotifications,
              onChanged: (bool value) {
                setState(() {
                  _weatherNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Notificaciones del Calendario de Tareas'),
              value: _taskCalendarNotifications,
              onChanged: (bool value) {
                setState(() {
                  _taskCalendarNotifications = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí iría la lógica para guardar los cambios de notificación
              },
              child: Text('GUARDAR CAMBIOS'),
            ),
          ],
        ),
      ),
    );
  }
}
