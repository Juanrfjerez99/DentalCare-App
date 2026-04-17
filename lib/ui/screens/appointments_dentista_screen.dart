import 'package:flutter/material.dart';

class AppointmentsDentistaScreen extends StatefulWidget {
  const AppointmentsDentistaScreen({super.key});

  @override
  State<AppointmentsDentistaScreen> createState() => _AppointmentsDentistaScreenState();
}

class _AppointmentsDentistaScreenState extends State<AppointmentsDentistaScreen> {
  DateTime _day = DateTime.now();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    _items = [
      {
        'id': 1,
        'date': '2025-01-10',
        'hour': '10:00',
        'reason': 'Limpieza dental',
        'status': 'pending',
        'patient_name': 'Juan Pérez',
      },
      {
        'id': 2,
        'date': '2025-01-10',
        'hour': '12:00',
        'reason': 'Revisión',
        'status': 'confirmed',
        'patient_name': 'María López',
      },
      {
        'id': 3,
        'date': '2025-01-11',
        'hour': '09:00',
        'reason': 'Empaste',
        'status': 'completed',
        'patient_name': 'Carlos Ruiz',
      },
    ];

    setState(() => _loading = false);
  }

  Future<void> _pickDay() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _day,
    );
    if (selected == null) return;
    setState(() => _day = selected);
    await _load();
  }

  Future<void> _changeStatus(Map<String, dynamic> row, String status) async {
    setState(() {
      row['status'] = status;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final dayText = _day.toIso8601String().split('T').first;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 🔹 Título
              Text(
                "Citas del día",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Selector de fecha
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Fecha seleccionada",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _pickDay,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dayText),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Resumen del día (solo dentista)
              Card(
                elevation: 3,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _pill("Total", _items.length.toString()),
                      _pill(
                        "Pendientes",
                        _items.where((e) => e['status'] == 'pending').length.toString(),
                      ),
                      _pill(
                        "Confirmadas",
                        _items.where((e) => e['status'] == 'confirmed').length.toString(),
                      ),
                      _pill(
                        "Completadas",
                        _items.where((e) => e['status'] == 'completed').length.toString(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Lista de citas
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_items.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No hay citas para mostrar"),
                  ),
                )
              else
                ..._items.map((row) => _appointmentCard(row)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // TARJETA DE CITA
  // ---------------------------------------------------
  Widget _appointmentCard(Map<String, dynamic> row) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text("${row['hour']} · ${row['reason']}"),
        subtitle: Text("${row['patient_name']} · ${_statusLabel(row['status'])}"),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _changeStatus(row, value),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'confirmed', child: Text('Confirmar')),
            PopupMenuItem(value: 'cancelled', child: Text('Cancelar')),
            PopupMenuItem(value: 'completed', child: Text('Completar')),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // PASTILLA DE RESUMEN
  // ---------------------------------------------------
  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text("$label: $value"),
    );
  }

  // ---------------------------------------------------
  // ESTADO EN TEXTO
  // ---------------------------------------------------
  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmada';
      case 'cancelled':
        return 'Cancelada';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }
}
