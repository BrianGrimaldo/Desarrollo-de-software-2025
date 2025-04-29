import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para trabajar con JSON

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: IAChatScreen());
  }
}

class IAChatScreen extends StatefulWidget {
  @override
  _IAChatScreenState createState() => _IAChatScreenState();
}

class _IAChatScreenState extends State<IAChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isProcessing = false;
  List<Map<String, String>> messages = [];

  // PON AQUÍ TU CLAVE API DE OPENAI
  final String apiKey = 'llave'; // Reemplaza con tu clave API

  // Función para enviar un mensaje a GPT-3/4
  Future<String> getGPTResponse(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $apiKey', // Usar la clave API que colocaste arriba
    };

    // Formato actualizado para la solicitud
    final body = json.encode({
      'model': 'gpt-3.5-turbo', // Usa el modelo más económico y simple
      'messages': [
        {
          "role": "system",
          "content": "Eres un asistente experto en agricultura.",
        },
        {"role": "user", "content": userMessage},
      ],
      'max_tokens': 150,
      'temperature': 0.7,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print(
        "Response status: ${response.statusCode}",
      ); // Verifica el código de estado
      print(
        "Response body: ${response.body}",
      ); // Imprime el cuerpo de la respuesta

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['choices'][0]['message']['content'].trim();
      } else {
        return 'Error en la conexión. Intenta de nuevo más tarde.';
      }
    } catch (e) {
      print('Error al comunicarse con la IA: $e'); // Captura y muestra el error
      return 'Hubo un error al comunicarse con la IA: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IA - Agricultura'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Align(
                    alignment:
                        messages[index]['sender'] == 'User'
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            messages[index]['sender'] == 'User'
                                ? Colors.blue[200]
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(messages[index]['message']!),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    enabled: !_isProcessing,
                  ),
                ),
                GestureDetector(
                  onTap:
                      _isProcessing
                          ? null
                          : () async {
                            // Agregar el mensaje del usuario
                            setState(() {
                              String userMessage = _controller.text;
                              messages.add({
                                'sender': 'User',
                                'message': userMessage,
                              });
                              _controller.clear();
                              _isProcessing = true;
                            });

                            // Obtener la respuesta de GPT
                            String aiResponse = await getGPTResponse(
                              _controller.text,
                            );

                            // Agregar la respuesta de la IA
                            setState(() {
                              messages.add({
                                'sender': 'IA',
                                'message': aiResponse,
                              });
                              _isProcessing = false;
                            });
                          },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
