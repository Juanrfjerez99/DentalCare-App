import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final claveController = TextEditingController();

  String _selectedRole = 'cliente';
  bool _loading = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String translateSupabaseError(Object e) {
    final error = e.toString();
    if (error.contains("AuthWeakPasswordException")) {
      return "La contraseña debe tener al menos 6 caracteres.";
    }
    if (error.contains("email")) {
      return "El correo no es válido o ya está registrado.";
    }
    if (error.contains("Invalid login credentials")) {
      return "Correo o contraseña incorrectos.";
    }
    return "Ocurrió un error inesperado. Inténtalo de nuevo.";
  }

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      showCustomSnackBar("Por favor, completa todos los campos.", Colors.orange);
      return;
    }
    // Validación de clave para dentista
    if (_selectedRole == 'dentista') {
      const String CLAVE_DENTISTA = "Dentista1234";

      if (claveController.text.trim() != CLAVE_DENTISTA) {
        setState(() => _loading = false);
        showCustomSnackBar("Clave incorrecta. No puedes registrarte como dentista.", Colors.red);
        return;
      }
    }

    setState(() => _loading = true);

    try {
      // 1. Crear usuario en Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        setState(() => _loading = false);
        showCustomSnackBar("No se pudo crear el usuario.", Colors.red);
        return;
      }

      // 2. Insertar en tabla según rol seleccionado
      final tableName = _selectedRole == 'cliente' ? 'usuario' : 'dentista';

      if (_selectedRole == 'cliente') {
        await Supabase.instance.client.from('usuario').update({
          'nombre': name,
          'telefono': phone,
          'correo': email,
          'rol': 'paciente',
        }).eq('id', user.id);
      } else {
        await Supabase.instance.client.from('dentista').insert({
          'id': user.id,
          'nombre': name,
          'telefono': phone,
          'correo': email,
          'rol': 'dentista',
        });
      }

      setState(() => _loading = false);
      showCustomSnackBar("Cuenta creada correctamente.", Colors.green);

      Navigator.pop(context);

    } catch (e) {
      setState(() => _loading = false);
      showCustomSnackBar(translateSupabaseError(e), Colors.red);
    }
  }

  void showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue.shade700),
        title: Text(
          "Crear cuenta",
          style: TextStyle(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // Selector tipo imagen (Cliente / Dentista)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = 'cliente'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'cliente'
                                    ? Colors.blue.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedRole == 'cliente'
                                      ? Colors.blue.shade400
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Cliente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRole == 'cliente'
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedRole = 'dentista'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'dentista'
                                    ? Colors.blue.shade100
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedRole == 'dentista'
                                      ? Colors.blue.shade400
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Dentista',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRole == 'dentista'
                                        ? Colors.blue.shade700
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Formulario
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("Nombre", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Nombre Completo",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text("Teléfono", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Ej: 612345678",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text("Correo", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "ejemplo@correo.com",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "********",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        if (_selectedRole == 'dentista') ...[
                          SizedBox(height: 16),
                          TextField(
                            controller: claveController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Clave dentista",
                              hintText: "Introduce la clave",
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 4,
                            ),
                            onPressed: _loading ? null : registerUser,
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Registrarse",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
