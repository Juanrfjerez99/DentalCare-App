import 'package:flutter/material.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() =>
      _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState
    extends State<SettingsNotificationsScreen> {
  bool citas = true;
  bool recordatorios = true;
  bool mensajes = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APPBAR PROFESIONAL
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue.shade700),
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FONDO DEGRADADO
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _switchCard(
                title: "Notificaciones de citas",
                value: citas,
                onChanged: (v) => setState(() => citas = v),
              ),

              _switchCard(
                title: "Recordatorios",
                value: recordatorios,
                onChanged: (v) => setState(() => recordatorios = v),
              ),

              _switchCard(
                title: "Mensajes del chat",
                value: mensajes,
                onChanged: (v) => setState(() => mensajes = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // TARJETA DE SWITCH PROFESIONAL
  // ---------------------------------------------------
  Widget _switchCard({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          value: value,
          activeColor: Colors.white,
          activeTrackColor: Colors.blue.shade700,
          inactiveTrackColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ),
    );
  }
}