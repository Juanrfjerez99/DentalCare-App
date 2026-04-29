import 'package:flutter/material.dart';
import '../services/citas_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentsDentistaScreen extends StatefulWidget {
  const AppointmentsDentistaScreen({super.key});

  @override
  State<AppointmentsDentistaScreen> createState() => _AppointmentsDentistaScreenState();
}

class _AppointmentsDentistaScreenState extends State<AppointmentsDentistaScreen> {
  final int _dentistaId = 1;

  DateTime _day = DateTime.now();
  List<Map<String, dynamic>> _items = [];
  List<DateTime> _diasConCitas = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadDiasConCitas();
  }

  // ============================================================
  // CARGAR CITAS DEL DÍA
  // ============================================================
  Future<void> _load() async {
    try {
      final data = await CitasService().getCitasPorDia(
        dentistaId: _dentistaId,
        fecha: _day,
      );

      print("CITAS RECIBIDAS: ${data.length}");
      print(data);

      _items = data.map((cita) {
        return {
          'id': cita['id'],
          'date': cita['fecha'],
          'hour': cita['hora'].substring(0, 5),
          'reason': cita['motivo'] ?? 'Cita',
          'status': cita['estado'],
          'patient_name': cita['usuario']['nombre'] ?? 'Paciente',
        };
      }).toList();

    } catch (e) {
      print("ERROR EN _load(): $e");
    }

    setState(() => _loading = false);

    final data = await CitasService().getCitasPorDia(
      dentistaId: _dentistaId,
      fecha: _day,
    );

    _items = data.map((cita) {
      return {
        'id': cita['id_cita'],
        'date': cita['fecha'],
        'hour': cita['hora'].substring(0, 5),
        'reason': cita['motivo'] ?? 'Cita',
        'status': cita['estado'],
        'patient_name': cita['usuario']['nombre'] ?? 'Paciente',
      };
    }).toList();

    setState(() => _loading = false);
  }

  // ============================================================
  // CARGAR DÍAS DEL MES CON CITAS
  // ============================================================
  Future<void> _loadDiasConCitas() async {
    _diasConCitas = await CitasService().getDiasConCitas(
      dentistaId: _dentistaId,
      year: _day.year,
      month: _day.month,
    );
    setState(() {});
  }

  // ============================================================
  // ABRIR CALENDARIO PERSONALIZADO
  // ============================================================
  Future<void> _pickDay() async {
    await _loadDiasConCitas();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _calendarWidget(),
    );
  }

  // ============================================================
  // CAMBIAR ESTADO DE UNA CITA
  // ============================================================
  Future<void> _changeStatus(Map<String, dynamic> row, String status) async {
    row['status'] = status;

    await CitasService().supabase
        .from('cita')
        .update({'estado': status})
        .eq('id_cita', row['id']);

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
              Text(
                "Citas del día",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

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

              // RESUMEN
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
                      _pill("Canceladas",
                          _items.where((e) => e['status'] == 'pending').length.toString()),
                      _pill("Confirmadas",
                          _items.where((e) => e['status'] == 'confirmed').length.toString()),
                      _pill("Completadas",
                          _items.where((e) => e['status'] == 'completed').length.toString()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // LISTA DE CITAS
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

  // ============================================================
  // TARJETA DE CITA
  // ============================================================
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

  // ============================================================
  // PASTILLA DE RESUMEN
  // ============================================================
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

  // ============================================================
  // ESTADO EN TEXTO
  // ============================================================
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

  // ============================================================
  // CALENDARIO PERSONALIZADO
  // ============================================================
  Widget _calendarWidget() {
    final firstDay = DateTime(_day.year, _day.month, 1);
    final lastDay = DateTime(_day.year, _day.month + 1, 0);

    List<Widget> days = [];

    for (int i = 1; i < firstDay.weekday; i++) {
      days.add(const SizedBox());
    }

    for (int d = 1; d <= lastDay.day; d++) {
      final date = DateTime(_day.year, _day.month, d);
      final hasCita = _diasConCitas.any((c) =>
      c.year == date.year && c.month == date.month && c.day == date.day);

      days.add(
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            setState(() => _day = date);
            _load();
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: hasCita ? Colors.blue.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasCita ? Colors.blue : Colors.grey.shade300,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              d.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasCita ? Colors.blue.shade900 : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Seleccionar día",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: days,
          ),
        ],
      ),
    );
  }
}
