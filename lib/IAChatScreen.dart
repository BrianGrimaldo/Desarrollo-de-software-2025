import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IAChatScreen extends StatefulWidget {
  const IAChatScreen({super.key});

  @override
  _IAChatScreenState createState() => _IAChatScreenState();
}

class _IAChatScreenState extends State<IAChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;
  List<Map<String, dynamic>> messages = [];

  // API Key de OpenAI
  final String apiKey = 'llave'; // Reemplaza con tu clave API

  // Sugerencias de preguntas relacionadas con agricultura
  final List<String> suggestions = [
    "¿Cómo prevenir plagas en cultivos orgánicos?",
    "¿Cuál es el mejor momento para sembrar maíz?",
    "¿Qué nutrientes necesitan los tomates?",
    "Técnicas de riego eficiente",
    "¿Cómo hacer compost casero?",
  ];

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida
    messages.add({
      'sender': 'IA',
      'message':
          '¡Hola! Soy tu asistente agrícola. ¿En qué puedo ayudarte hoy?',
      'timestamp': DateTime.now(),
    });
  }

  // Función para enviar un mensaje a GPT-3.5
  Future<String> getGPTResponse(String userMessage) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = json.encode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          "role": "system",
          "content":
              "Eres un asistente experto en agricultura. Proporciona información útil, práctica y breve sobre cultivos, técnicas agrícolas, control de plagas, fertilizantes orgánicos y agricultura sostenible. Tus respuestas deben ser claras, educativas y directas.",
        },
        {"role": "user", "content": userMessage},
      ],
      'max_tokens': 250,
      'temperature': 0.7,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['choices'][0]['message']['content'].trim();
      } else {
        print("Error body: ${response.body}");
        return 'Error en la conexión (${response.statusCode}). Intenta de nuevo más tarde.';
      }
    } catch (e) {
      print('Error al comunicarse con la IA: $e');
      return 'Hubo un problema de conexión. Verifica tu internet e intenta de nuevo.';
    }
  }

  // Para desplazarse automáticamente al último mensaje
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      messages.add({
        'sender': 'User',
        'message': userMessage,
        'timestamp': DateTime.now(),
      });
      _controller.clear();
      _isProcessing = true;
    });

    _scrollToBottom();

    // Obtener respuesta de GPT
    String aiResponse = await getGPTResponse(userMessage);

    setState(() {
      messages.add({
        'sender': 'IA',
        'message': aiResponse,
        'timestamp': DateTime.now(),
      });
      _isProcessing = false;
    });

    _scrollToBottom();
  }

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
          // Banner explicativo
          _buildInfoBanner(),

          // Lista de mensajes
          Expanded(child: _buildMessagesList()),

          // Indicador de escritura
          if (_isProcessing) _buildTypingIndicator(),

          // Sugerencias de preguntas
          if (messages.length < 3) _buildSuggestions(),

          // Barra de entrada de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  // AppBar personalizado
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color(0xFF4CAF50),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.spa, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12),
          Text(
            'Asistente Agrícola',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            // Reiniciar la conversación
            setState(() {
              messages = [
                {
                  'sender': 'IA',
                  'message':
                      '¡Hola! Soy tu asistente agrícola. ¿En qué puedo ayudarte hoy?',
                  'timestamp': DateTime.now(),
                },
              ];
            });
          },
          tooltip: 'Reiniciar conversación',
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

  // Banner informativo
  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFA5D6A7), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Color(0xFF2E7D32)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este asistente de IA te ayuda con dudas sobre agricultura, cultivos y técnicas de siembra.',
              style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  // Lista de mensajes
  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final bool isUser = message['sender'] == 'User';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: isUser ? 64 : 0,
              right: isUser ? 0 : 64,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Color(0xFF4CAF50) : Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
                bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['message'],
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTime(message['timestamp']),
                  style: TextStyle(
                    color:
                        isUser ? Colors.white.withOpacity(0.7) : Colors.black54,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Indicador de escritura
  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(left: 16, bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          16,
        ).copyWith(bottomLeft: Radius.circular(0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [_buildDot(0), _buildDot(1), _buildDot(2)],
      ),
    );
  }

  // Dot animado para el indicador de escritura
  Widget _buildDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(opacity: (value + index / 3) % 1.0, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // Sugerencias de preguntas
  Widget _buildSuggestions() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                _controller.text = suggestions[index];
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE8F5E9),
                foregroundColor: Color(0xFF2E7D32),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Color(0xFFA5D6A7)),
                ),
              ),
              child: Text(
                suggestions[index].length > 25
                    ? '${suggestions[index].substring(0, 22)}...'
                    : suggestions[index],
                style: TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  // Campo de entrada de mensajes
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Escribe tu consulta agrícola...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                    onPressed: () {
                      _controller.clear();
                    },
                  ),
                ),
                enabled: !_isProcessing,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _isProcessing ? null : _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isProcessing ? Colors.grey[400] : Color(0xFF4CAF50),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isProcessing
                            ? Colors.grey[400]
                            : Color(0xFF4CAF50))!
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // Formateador de tiempo
  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';

    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
