import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/citas_service.dart';

class AppointmentsClienteScreen extends StatefulWidget {
  const AppointmentsClienteScreen({super.key});

  @override
  State<AppointmentsClienteScreen> createState() => _AppointmentsClienteScreenState();
}

class _AppointmentsClienteScreenState extends State<AppointmentsClienteScreen> {
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? selectedDay;

  List<String> horasOcupadas = [];

  List<Map<String, dynamic>> citasUsuario = [];
  bool loadingCitas = true;

  @override
  void initState() {
    super.initState();
    _loadCitasUsuario();
  }

  void _loadHorasOcupadas(DateTime date) async {
    horasOcupadas = await CitasService().getHorasOcupadas(date);
    _showAvailableHours(date);
  }

  Future<bool> _isDiaCompleto(DateTime date) async {
    return await CitasService().diaCompleto(date);
  }

  void _loadCitasUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await CitasService().getCitasUsuario(user.id);

    setState(() {
      citasUsuario = data;
      loadingCitas = false;
    });
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

              Text(
                "Citas",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

              _buildMonthNavigation(),

              const SizedBox(height: 16),

              _buildCalendarMonth(),

              const SizedBox(height: 24),

              Text(
                "Próximas citas",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: loadingCitas
                    ? const Center(child: CircularProgressIndicator())
                    : citasUsuario.isEmpty
                    ? const Center(
                  child: Text(
                    "No tienes citas próximas",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: citasUsuario.length,
                  itemBuilder: (context, index) {
                    final cita = citasUsuario[index];

                    return _appointmentCard(
                      hora: cita['hora'],
                      paciente: "Tú",
                      motivo: cita['motivo'] ?? "Cita programada",
                      fecha: cita['fecha'],
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

  // ---------------------------------------------------
  // NAVEGACIÓN ENTRE MESES
  // ---------------------------------------------------
  Widget _buildMonthNavigation() {
    final monthName = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ][currentMonth.month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue.shade700),
          onPressed: () {
            setState(() {
              currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
            });
          },
        ),
        Text(
          "$monthName ${currentMonth.year}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.blue.shade700),
          onPressed: () {
            setState(() {
              currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
            });
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // CALENDARIO MENSUAL (ACTUALIZADO)
  // ---------------------------------------------------
  Widget _buildCalendarMonth() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    int startWeekday = firstDay.weekday;
    int totalDays = lastDay.day;

    List<Widget> dayWidgets = [];

    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);

      final isSelected = selectedDay != null &&
          selectedDay!.day == day &&
          selectedDay!.month == currentMonth.month &&
          selectedDay!.year == currentMonth.year;

      final bool isPast = date.isBefore(
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );

      final bool isSunday = date.weekday == DateTime.sunday;

      dayWidgets.add(
        FutureBuilder<bool>(
          future: _isDiaCompleto(date),
          builder: (context, snapshot) {
            final isFull = snapshot.data == true;
            final bool disabled = isPast || isSunday || isFull;

            return GestureDetector(
              onTap: disabled
                  ? null
                  : () {
                setState(() {
                  selectedDay = date;
                });
                _loadHorasOcupadas(date);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: disabled
                      ? Colors.grey.shade300
                      : isSelected
                      ? Colors.blue.shade700
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: disabled
                        ? Colors.grey.shade600
                        : isSelected
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _WeekdayLabel("L"),
            _WeekdayLabel("M"),
            _WeekdayLabel("X"),
            _WeekdayLabel("J"),
            _WeekdayLabel("V"),
            _WeekdayLabel("S"),
            _WeekdayLabel("D"),
          ],
        ),
        const SizedBox(height: 8),

        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: dayWidgets,
        ),
      ],
    );
  }

  // ---------------------------------------------------
  // HORAS DISPONIBLES
  // ---------------------------------------------------
  void _showAvailableHours(DateTime date) {
    final hours = [
      "09:00", "10:00", "11:00", "12:00",
      "16:00", "17:00", "18:00",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Horas disponibles",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: hours.map((hora) {
                  final isOcupada = horasOcupadas.contains(hora);

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOcupada ? Colors.grey : Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isOcupada
                        ? null
                        : () async {
                      Navigator.pop(context);

                      final user = Supabase.instance.client.auth.currentUser;

                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Debes iniciar sesión para reservar una cita"),
                          ),
                        );
                        return;
                      }

                      final userId = user.id;
                      final dentistaId = 1;

                      await CitasService().crearCita(
                        fecha: date,
                        hora: hora,
                        userId: userId,
                        dentistaId: dentistaId,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cita reservada para las $hora")),
                      );

                      _loadCitasUsuario();
                      setState(() {});
                    },
                    child: Text(hora),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------
  // TARJETA DE CITA
  // ---------------------------------------------------
  Widget _appointmentCard({
    required String hora,
    required String paciente,
    required String motivo,
    String? fecha,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          child: Text(
            hora.substring(0, 5),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        title: Text(paciente),
        subtitle: Text(
          fecha != null
              ? "${fecha.substring(0, 10)} · $motivo"
              : motivo,
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;
  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
