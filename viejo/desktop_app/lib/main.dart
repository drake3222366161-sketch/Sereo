import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Paleta SEREO
const primario = Color(0xFF1D9E75);
const primarioOscuro = Color(0xFF0F6E56);
const primarioMuyOscuro = Color(0xFF04342C);
const fondoAcento = Color(0xFFE1F5EE);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEREO - Panel de Bienestar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primario),
      ),
      home: const LoginScreen(),
    );
  }
}

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

    final url = Uri.parse('http://localhost/sereo/backend/public/index.php');

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

      final rol = datos['usuario']['rol'];

      // Esta app es SOLO para Bienestar y Admin
      if (rol != 'bienestar' && rol != 'admin') {
        setState(() => _error =
            'Esta cuenta no tiene acceso al panel de escritorio.');
        return;
      }

      if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              nombreUsuario: datos['usuario']['nombre'],
                rol: rol,
              ),
            ),
          );
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Panel izquierdo decorativo
          Expanded(
            flex: 4,
            child: Container(
              color: fondoAcento,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_moon_outlined, color: primarioOscuro, size: 90),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'SEREO — Panel de gestión de Bienestar Universitario',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: primarioMuyOscuro, fontSize: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Panel derecho: formulario
          Expanded(
            flex: 5,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Iniciar sesión',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Acceso exclusivo de personal autorizado',
                          style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 24),
                      if (_error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCEBEB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_error!,
                              style: const TextStyle(color: Color(0xFF791F1F))),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextField(
                        controller: _correoController,
                        decoration: const InputDecoration(
                          labelText: 'Correo institucional',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _contrasenaController,
                        obscureText: _ocultarContrasena,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_ocultarContrasena
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () =>
                                setState(() => _ocultarContrasena = !_ocultarContrasena),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primario,
                          foregroundColor: primarioMuyOscuro,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _cargando ? null : _iniciarSesion,
                        child: _cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Ingresar al panel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}