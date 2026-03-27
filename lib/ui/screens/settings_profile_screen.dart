import 'package:flutter/material.dart';

class SettingsProfileScreen extends StatelessWidget {
  const SettingsProfileScreen({super.key});

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
          "Perfil",
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

                const SizedBox(height: 10),

                // AVATAR PROFESIONAL
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.blue.shade700,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                // INPUT: NOMBRE
                _inputField(
                  label: "Nombre",
                  hint: "Tu nombre completo",
                ),

                const SizedBox(height: 16),

                // INPUT: CORREO
                _inputField(
                  label: "Correo",
                  hint: "ejemplo@correo.com",
                  keyboard: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // INPUT: TELÉFONO
                _inputField(
                  label: "Teléfono",
                  hint: "Ej: 612345678",
                  keyboard: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                // INPUT: CONTRASEÑA
                _inputField(
                  label: "Contraseña",
                  hint: "********",
                  obscure: true,
                ),

                const SizedBox(height: 30),

                // BOTÓN GUARDAR CAMBIOS
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Guardar cambios",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // INPUT FIELD PROFESIONAL
  // ---------------------------------------------------
  Widget _inputField({
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}