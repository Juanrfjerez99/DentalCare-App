import 'package:flutter/material.dart';

class SettingsLanguageScreen extends StatefulWidget {
  const SettingsLanguageScreen({super.key});

  @override
  State<SettingsLanguageScreen> createState() => _SettingsLanguageScreenState();
}

class _SettingsLanguageScreenState extends State<SettingsLanguageScreen> {
  String selected = "Español";

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
          "Idioma",
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
              _languageTile("Español"),
              _languageTile("Inglés"),
              _languageTile("Francés"),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // TARJETA DE IDIOMA PROFESIONAL
  // ---------------------------------------------------
  Widget _languageTile(String idioma) {
    final bool isSelected = selected == idioma;

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(
          idioma,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: Colors.blue.shade700,
          size: 28,
        )
            : Icon(
          Icons.circle_outlined,
          color: Colors.grey.shade400,
          size: 26,
        ),
        onTap: () {
          setState(() {
            selected = idioma;
          });
        },
      ),
    );
  }
}