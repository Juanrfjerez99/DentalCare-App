import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _loading = true;

  // Datos de ejemplo (antes venían de SQLite)
  List<Map<String, dynamic>> _patients = [
    {
      'name': 'Juan Pérez',
      'message': 'Gracias',
      'time': '10:45',
    },
    {
      'name': 'María López',
      'message': '¿Cómo puedo pedir revisión?',
      'time': '09:12',
    },
    {
      'name': 'Carlos Ruiz',
      'message': 'Perfecto, nos vemos mañana',
      'time': 'Ayer',
    },
    {
      'name': 'Ana Torres',
      'message': 'Muchas Gracias',
      'time': 'Ayer',
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    // Simulación de carga (antes era db.listPatients())
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() => _loading = false);
  }

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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                  children: _patients.map((p) {
                    return _chatTile(
                      context: context,
                      nombre: p['name'],
                      mensaje: p['message'],
                      hora: p['time'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
