import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'register_screen.dart';
import 'home_estudiante.dart';
import 'home_staff.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _cargando = false;
  String? _error;

  Future<void> _iniciarSesion() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final url = Uri.parse('http://localhost/sereo/backend/public/login.php');

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _correoController.text.trim(),
          'contrasena': _contrasenaController.text,
        }),
      );

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        setState(() => _error = datos['error']);
        return;
      }

      _navegarSegunRol(datos['usuario']);
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Aquí está la clave de "una sola app": según el rol que devolvió
  // el backend, navegamos a una pantalla distinta.
  void _navegarSegunRol(Map<String, dynamic> usuario) {
    if (!mounted) return;

    final rol = usuario['rol'];

    if (rol == 'estudiante') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeEstudiante(
            nombreEstudiante: usuario['nombre'],
            programaAcademico: usuario['programa_academico'],
          ),
        ),
      );
    } else {
      // 'bienestar' o 'admin'
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeStaff(
            nombreUsuario: usuario['nombre'],
            rol: rol,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: fondoAcento, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, color: primarioOscuro, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('SEREO',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Acompañamiento psicológico universitario',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: textoSecundario)),
                  const SizedBox(height: 32),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(color: Color(0xFF791F1F), fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text('Correo institucional',
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'nombre@ucundinamarca.edu.co'),
                  ),
                  const SizedBox(height: 16),

                  const Text('Contraseña',
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _contrasenaController,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                    onSubmitted: (_) => _iniciarSesion(),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primario,
                      foregroundColor: primarioMuyOscuro,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    onPressed: _cargando ? null : _iniciarSesion,
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes cuenta?', style: TextStyle(fontSize: 13)),
                      TextButton(
                        onPressed: _cargando
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                        child: const Text('Regístrate',
                            style: TextStyle(color: primarioOscuro, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Solo estudiantes pueden registrarse aquí. El personal de '
                    'Bienestar y Administración recibe su cuenta directamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: textoMuted),
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
