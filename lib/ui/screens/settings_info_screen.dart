import 'package:flutter/material.dart';

class SettingsInfoScreen extends StatelessWidget {
  const SettingsInfoScreen({super.key});

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
          "Información de la app",
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // FONDO DEGRADADO COMPLETO
      body: Container(
        width: double.infinity,
        height: double.infinity,
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

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              // LOGO CENTRADO
              Center(
                child: SizedBox(
                  height: 150,
                  child: Image.asset(
                    'assets/LogoDentalCare.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 1),

              // VERSIÓN
              Center(
                child: Text(
                  "Versión 1.0.0",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // TARJETA: DESCRIPCIÓN
              _infoCard(
                title: "Descripción",
                content:
                "DentalCare es una aplicación diseñada para gestionar citas, "
                    "historial clínico y comunicación con pacientes de forma sencilla "
                    "y eficiente.",
              ),

              // TARJETA: SOPORTE
              _infoCard(
                title: "Soporte",
                contentWidget: Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      "soportedentalcare@gmail.com",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // TARJETA: DESARROLLADORES (CORREGIDA)
              _infoCard(
                title: "Desarrollo",
                contentWidget: Row(
                  children: [
                    const Text(
                      "Equipo DentalCare",
                      style: TextStyle(fontSize: 16),
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
  // TARJETA DE INFORMACIÓN PROFESIONAL
  // ---------------------------------------------------
  Widget _infoCard({
    required String title,
    String? content,
    Widget? contentWidget,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 8),
            contentWidget ??
                Text(
                  content ?? "",
                  style: const TextStyle(fontSize: 16),
                ),
          ],
        ),
      ),
    );
  }
}