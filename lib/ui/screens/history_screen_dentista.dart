import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/citas_service.dart';

class HistorialDentistaScreen extends StatefulWidget {
  const HistorialDentistaScreen({super.key});

  @override
  State<HistorialDentistaScreen> createState() => _HistorialDentistaScreenState();
}

class _HistorialDentistaScreenState extends State<HistorialDentistaScreen> {
  List<Map<String, dynamic>> historial = [];
  List<String> deletedIds = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDeletedIds();
  }

  // ---------------------------------------------------
  // CARGAR IDS BORRADOS DE SharedPreferences
  // ---------------------------------------------------
  Future<void> _loadDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    deletedIds = prefs.getStringList("deleted_history_ids_dentista") ?? [];
    _loadHistorial();
  }

  // ---------------------------------------------------
  // GUARDAR IDS BORRADOS
  // ---------------------------------------------------
  Future<void> _saveDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("deleted_history_ids_dentista", deletedIds);
  }

  // ---------------------------------------------------
  // CARGAR HISTORIAL DEL DENTISTA
  // ---------------------------------------------------
  Future<void> _loadHistorial() async {
    try {
      final data = await CitasService().getCitasDentista();

      for (var cita in data) {
        cita['id'] = cita['id_cita'].toString();
      }

      final filtradas = data.where((cita) =>
      (cita['estado'] == 'completada' || cita['estado'] == 'cancelada') &&
          !deletedIds.contains(cita['id'])
      ).toList();

      filtradas.sort((a, b) {
        final fechaA = DateTime.parse("${a['fecha']} ${a['hora']}");
        final fechaB = DateTime.parse("${b['fecha']} ${b['hora']}");
        return fechaB.compareTo(fechaA);
      });

      setState(() {
        historial = filtradas;
        loading = false;
      });
    } catch (e) {
      print("ERROR EN HISTORIAL DENTISTA: $e");
      setState(() => loading = false);
    }
  }

  // ---------------------------------------------------
  // BORRAR TODO (solo visual)
  // ---------------------------------------------------
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
            onPressed: () async {
              for (var cita in historial) {
                deletedIds.add(cita['id']);
              }
              await _saveDeletedIds();

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

  // ---------------------------------------------------
  // BORRAR UN ELEMENTO (solo visual)
  // ---------------------------------------------------
  void _confirmarEliminarItem(int index) {
    final id = historial[index]['id'];

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
            onPressed: () async {
              deletedIds.add(id);
              await _saveDeletedIds();

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
          colors: [Colors.white, Colors.blue.shade50],
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
                    "Historial de citas",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: historial.isEmpty ? null : _confirmarEliminarTodo,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : historial.isEmpty
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

                    return HistoryItemDentista(
                      tratamiento: item["motivo"] ?? "Cita",
                      paciente: item["usuario"]?["nombre"] ?? "Paciente",
                      fecha: item["fecha"]?.toString().split(" ").first ?? "",
                      hora: item["hora"]?.toString().substring(0, 5) ?? "",
                      estado: item["estado"],
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
class HistoryItemDentista extends StatelessWidget {
  final String fecha;
  final String hora;
  final String paciente;
  final String tratamiento;
  final String estado;
  final VoidCallback onDelete;

  const HistoryItemDentista({
    super.key,
    required this.fecha,
    required this.hora,
    required this.paciente,
    required this.tratamiento,
    required this.estado,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool esCompletada = estado == "completada";

    final color = esCompletada ? Colors.green.shade700 : Colors.red.shade700;
    final icono = esCompletada ? Icons.check : Icons.close;
    final estadoTexto = esCompletada ? "Completada" : "Cancelada";

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icono, color: Colors.white),
        ),
        title: Text(
          "$hora · $tratamiento",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$paciente • $fecha • $estadoTexto"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
