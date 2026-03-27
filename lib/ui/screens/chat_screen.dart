import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              // TÍTULO
              Text(
                "Chat",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: [
                    _chatTile(
                      context: context,
                      nombre: "Juan Pérez",
                      mensaje: "Gracias",
                      hora: "10:45",
                    ),
                    _chatTile(
                      context: context,
                      nombre: "María López",
                      mensaje: "¿Cómo puedo pedir revisión?",
                      hora: "09:12",
                    ),
                    _chatTile(
                      context: context,
                      nombre: "Carlos Ruiz",
                      mensaje: "Perfecto, nos vemos mañana",
                      hora: "Ayer",
                    ),
                    _chatTile(
                      context: context,
                      nombre: "Ana Torres",
                      mensaje: "Muchas Gracias",
                      hora: "Ayer",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // TARJETA DE CHAT
  // ---------------------------------------------------
  Widget _chatTile({
    required BuildContext context,
    required String nombre,
    required String mensaje,
    required String hora,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.blue.shade700,
          child: Text(
            nombre[0],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          mensaje,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          hora,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(nombre: nombre),
            ),
          );
        },
      ),
    );
  }
}