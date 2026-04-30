import 'package:flutter/material.dart';
import '../services/citas_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentsDentistaScreen extends StatefulWidget {
  const AppointmentsDentistaScreen({super.key});

  @override
  State<AppointmentsDentistaScreen> createState() => _AppointmentsDentistaScreenState();
}

class _AppointmentsDentistaScreenState extends State<AppointmentsDentistaScreen> {
  DateTime _day = DateTime.now();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _todasLasCitas = [];
  List<DateTime> _diasConCitas = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadDiasConCitas();
  }

  // ---------------------------------------------------
  // CARGAR CITAS DEL DÍA (TODAS)
  // ---------------------------------------------------
  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final data = await CitasService().getCitasPorDia(_day);

      _todasLasCitas = data.map((cita) {
        return {
          'id': cita['id_cita'],
          'date': cita['fecha'],
          'hour': cita['hora'].substring(0, 5),
          'reason': cita['motivo'] ?? 'Cita',
          'status': cita['estado'],
          'patient_name': cita['usuario']?['nombre'] ?? 'Paciente',
        };
      }).toList();

      _items = _todasLasCitas.where((cita) =>
      cita['status'] == 'pendiente' ||
          cita['status'] == 'confirmada'
      ).toList();

    } catch (e) {
      print("ERROR EN _load(): $e");
    }

    setState(() => _loading = false);
  }

  // ---------------------------------------------------
  // CARGAR DÍAS DEL MES CON CITAS
  // ---------------------------------------------------
  Future<void> _loadDiasConCitas() async {
    _diasConCitas = await CitasService().getDiasConCitas(
      year: _day.year,
      month: _day.month,
    );
    setState(() {});
  }

  // ---------------------------------------------------
  // ABRIR CALENDARIO
  // ---------------------------------------------------
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

  // ---------------------------------------------------
  // CONFIRMAR CAMBIO DE ESTADO
  // ---------------------------------------------------
  Future<void> _changeStatus(Map<String, dynamic> row, String status) async {
    String mensaje = "";

    switch (status) {
      case 'confirmada':
        mensaje = "¿Seguro que quieres confirmar esta cita?";
        break;
      case 'cancelada':
        mensaje = "¿Seguro que quieres cancelar esta cita?";
        break;
      case 'completada':
        mensaje = "¿Seguro que quieres marcar esta cita como completada?";
        break;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmación"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Sí", style: TextStyle(color: Colors.blue)),
            onPressed: () async {
              Navigator.pop(context);

              await CitasService().supabase
                  .from('cita')
                  .update({'estado': status})
                  .eq('id_cita', row['id']);

              setState(() {
                row['status'] = status;
              });

              await _load();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // NOMBRE DEL MES
  // ---------------------------------------------------
  String _nombreMes(int mes) {
    const meses = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];
    return meses[mes - 1];
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

              // ---------------------------------------------------
              // RESUMEN DE TODAS LAS CITAS
              // ---------------------------------------------------
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
                      _pill("Total", _todasLasCitas.length.toString()),
                      _pill("Canceladas",
                          _todasLasCitas.where((e) => e['status'] == 'cancelada').length.toString()),
                      _pill("Confirmadas",
                          _todasLasCitas.where((e) => e['status'] == 'confirmada').length.toString()),
                      _pill("Completadas",
                          _todasLasCitas.where((e) => e['status'] == 'completada').length.toString()),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

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
            PopupMenuItem(value: 'confirmada', child: Text('Confirmar')),
            PopupMenuItem(value: 'cancelada', child: Text('Cancelar')),
            PopupMenuItem(value: 'completada', child: Text('Completar')),
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
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      default:
        return status;
    }
  }

  // ---------------------------------------------------
  // CALENDARIO PERSONALIZADO
  // ---------------------------------------------------
  Widget _calendarWidget() {
    DateTime mesActual = DateTime(_day.year, _day.month);

    return StatefulBuilder(
      builder: (context, setStateModal) {
        Future<void> cambiarMes(int delta) async {
          mesActual = DateTime(mesActual.year, mesActual.month + delta);

          _diasConCitas = await CitasService().getDiasConCitas(
            year: mesActual.year,
            month: mesActual.month,
          );

          setStateModal(() {});
        }

        final firstDay = DateTime(mesActual.year, mesActual.month, 1);
        final lastDay = DateTime(mesActual.year, mesActual.month + 1, 0);

        List<Widget> days = [];

        for (int i = 1; i < firstDay.weekday; i++) {
          days.add(const SizedBox());
        }

        for (int d = 1; d <= lastDay.day; d++) {
          final date = DateTime(mesActual.year, mesActual.month, d);
          final hasCita = _diasConCitas.any((c) =>
          c.year == date.year && c.month == date.month && c.day == date.day);

          final isSelected = date.year == _day.year &&
              date.month == _day.month &&
              date.day == _day.day;

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
                  color: isSelected
                      ? Colors.blue.shade300
                      : hasCita
                      ? Colors.blue.shade100
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue.shade900
                        : hasCita
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  d.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : hasCita
                        ? Colors.blue.shade900
                        : Colors.black,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28),
                    onPressed: () => cambiarMes(-1),
                  ),
                  Text(
                    "${_nombreMes(mesActual.month)} ${mesActual.year}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 28),
                    onPressed: () => cambiarMes(1),
                  ),
                ],
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
      },
    );
  }
}