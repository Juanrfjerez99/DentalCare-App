import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'home_screen.dart';

// Pantallas según rol
import 'appointments_cliente_screen.dart';
import 'appointments_dentista_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _selectedRole = 'cliente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const SizedBox(height: 30),
                  Center(
                    child: Image.asset(
                      'assets/LogoDentalCare.png',
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gestión de citas para tu clínica dental',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Selector de rol
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Cliente'),
                          selected: _selectedRole == 'cliente',
                          onSelected: (_) => setState(() => _selectedRole = 'cliente'),
                          selectedColor: Colors.blue.shade100,
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Dentista'),
                          selected: _selectedRole == 'dentista',
                          onSelected: (_) => setState(() => _selectedRole = 'dentista'),
                          selectedColor: Colors.blue.shade100,
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
                        const Text('Correo', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'ejemplo@correo.com',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '********',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Botón de login
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
                            onPressed: () async {
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();

                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Rellena todos los campos")),
                                );
                                return;
                              }

                              try {
                                // 1. Login normal
                                final response = await supabase.auth.signInWithPassword(
                                  email: email,
                                  password: password,
                                );

                                final userId = response.user?.id;
                                if (userId == null) throw Exception("No se pudo obtener el usuario");

                                // 2. Buscar en ambas tablas
                                final usuario = await supabase
                                    .from('usuario')
                                    .select('rol')
                                    .eq('id', userId)
                                    .maybeSingle();

                                final dentista = await supabase
                                    .from('dentista')
                                    .select('rol')
                                    .eq('id', userId)
                                    .maybeSingle();

                                // 3. Determinar rol real
                                String? rolReal;
                                if (usuario != null) rolReal = usuario['rol'];
                                if (dentista != null) rolReal = dentista['rol'];

                                if (rolReal == null) {
                                  throw Exception("ROL_NO_ENCONTRADO");
                                }

                                // 4. Validación estricta
                                if (_selectedRole == 'cliente' && rolReal != 'paciente') {
                                  throw Exception("ROL_INCORRECTO");
                                }

                                if (_selectedRole == 'dentista' && rolReal != 'dentista') {
                                  throw Exception("ROL_INCORRECTO");
                                }

                                // 5. Acceso permitido → Pantalla según rol
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeScreen(
                                      isAdmin: rolReal == 'dentista',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                // Error de rol incorrecto
                                if (e.toString().contains("ROL_INCORRECTO")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("No puedes iniciar sesión con este tipo de cuenta."),
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  );
                                  await supabase.auth.signOut();
                                  return;
                                }

                                if (e.toString().contains("ROL_NO_ENCONTRADO")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Tu cuenta no está configurada correctamente."),
                                      backgroundColor: Colors.red.shade600,
                                    ),
                                  );
                                  await supabase.auth.signOut();
                                  return;
                                }

                                // Otros errores
                                String mensajeError = "Ha ocurrido un error inesperado.";
                                if (e.toString().contains("invalid_credentials")) {
                                  mensajeError = "Correo o contraseña incorrectos.";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(mensajeError),
                                    backgroundColor: Colors.red.shade600,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Iniciar sesión',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Crear cuenta nueva',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
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
