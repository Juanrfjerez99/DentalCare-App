import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Lista dinámica del historial
  List<Map<String, String>> historial = [
    {
      "tratamiento": "Limpieza dental",
      "paciente": "Juan Pérez",
      "fecha": "19 Mar 2026"
    },
    {
      "tratamiento": "Empaste",
      "paciente": "María López",
      "fecha": "20 Mar 2026"
    },
    {
      "tratamiento": "Ortodoncia",
      "paciente": "Carlos Ruiz",
      "fecha": "22 Mar 2026"
    },
    {
      "tratamiento": "Extracción",
      "paciente": "Ana Torres",
      "fecha": "25 Mar 2026"
    },
  ];

  // Confirmación para borrar todo el historial
  void _confirmarEliminarTodo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar historial"),
        content: const Text("¿Seguro que quieres eliminar todo el historial?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                historial.clear();
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Confirmación para borrar un elemento
  void _confirmarEliminarItem(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar entrada"),
        content: const Text("¿Seguro que quieres eliminar esta entrada?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() {
                historial.removeAt(index);
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Historial",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),

                  // Botón para borrar todo
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: historial.isEmpty ? null : _confirmarEliminarTodo,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: historial.isEmpty
                    ? const Center(
                  child: Text(
                    "No hay historial disponible",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final item = historial[index];
                    return HistoryItem(
                      tratamiento: item["tratamiento"]!,
                      paciente: item["paciente"]!,
                      fecha: item["fecha"]!,
                      onDelete: () => _confirmarEliminarItem(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// TARJETA DE HISTORIAL CON PAPELERA
// ---------------------------------------------------
class HistoryItem extends StatelessWidget {
  final String fecha;
  final String paciente;
  final String tratamiento;
  final VoidCallback onDelete;

  const HistoryItem({
    super.key,
    required this.fecha,
    required this.paciente,
    required this.tratamiento,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          tratamiento,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$paciente • $fecha"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
