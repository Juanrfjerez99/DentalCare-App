import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                "Historial",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  children: const [
                    HistoryItem(
                      fecha: "19 Mar 2026",
                      paciente: "Juan Pérez",
                      tratamiento: "Limpieza dental",
                    ),
                    HistoryItem(
                      fecha: "20 Mar 2026",
                      paciente: "María López",
                      tratamiento: "Empaste",
                    ),
                    HistoryItem(
                      fecha: "22 Mar 2026",
                      paciente: "Carlos Ruiz",
                      tratamiento: "Ortodoncia",
                    ),
                    HistoryItem(
                      fecha: "25 Mar 2026",
                      paciente: "Ana Torres",
                      tratamiento: "Extracción",
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
}

// ---------------------------------------------------
// TARJETA DE HISTORIAL INTERACTIVA
// ---------------------------------------------------
class HistoryItem extends StatefulWidget {
  final String fecha;
  final String paciente;
  final String tratamiento;

  const HistoryItem({
    super.key,
    required this.fecha,
    required this.paciente,
    required this.tratamiento,
  });

  @override
  State<HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  bool completed = false;

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
        leading: GestureDetector(
          onTap: () {
            setState(() {
              completed = !completed;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: completed ? Colors.blue.shade700 : Colors.white,
              border: Border.all(
                color: completed ? Colors.blue.shade700 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: completed
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        ),
        title: Text(
          widget.tratamiento,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("${widget.paciente} • ${widget.fecha}"),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}