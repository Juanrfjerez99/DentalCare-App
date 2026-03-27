import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  final bool isAdmin;

  const AppointmentsScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? selectedDay;

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
                child: ListView(
                  children: [
                    _appointmentCard(
                      hora: "10:00",
                      paciente: "Juan Pérez",
                      motivo: "Limpieza dental",
                    ),
                    _appointmentCard(
                      hora: "12:30",
                      paciente: "María López",
                      motivo: "Revisión general",
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
  // CALENDARIO MENSUAL
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

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedDay = date;
            });
            _showAvailableHours(date);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: Text(
              day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Has seleccionado $hora")),
                      );
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
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          if (widget.isAdmin) {
            _showAppointmentActions(hora, paciente);
          }
        },
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade700,
          child: Text(
            hora,
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        title: Text(paciente),
        subtitle: Text(motivo),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue.shade700),
      ),
    );
  }

  // ---------------------------------------------------
  // MENÚ DE ACCIONES (solo Admin)
  // ---------------------------------------------------
  void _showAppointmentActions(String hora, String paciente) {
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
                "Acciones para la cita",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text("Confirmar cita"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    "¿Estás seguro de que quieres confirmar la cita?",
                    "Cita confirmada",
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red),
                title: Text("Cancelar cita"),
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    "¿Estás seguro de que quieres cancelar la cita?",
                    "Cita cancelada",
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------
  // CONFIRMACIÓN (Sí / No)
  // ---------------------------------------------------
  void _confirmAction(String question, String successMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmación"),
          content: Text(question),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Sí"),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(successMessage)),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------
// ETIQUETA DE DÍA DE LA SEMANA
// ---------------------------------------------------
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