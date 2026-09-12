import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Paleta SEREO
const primario = Color(0xFF1D9E75);
const primarioOscuro = Color(0xFF0F6E56);
const primarioMuyOscuro = Color(0xFF04342C);
const fondoAcento = Color(0xFFE1F5EE);
const textoSecundario = Color(0xFF5F5E5A);
const textoMuted = Color(0xFF888780);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEREO',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAFAF8),
        colorScheme: ColorScheme.fromSeed(seedColor: primario),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
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

      // Esta app es SOLO para estudiantes
      if (rol != 'estudiante') {
        setState(() => _error =
            'Esta cuenta no corresponde a un estudiante. Usa la app de escritorio de Bienestar/Admin.');
        return;
      }

      if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              nombreEstudiante: datos['usuario']['nombre'],
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
                      decoration: const BoxDecoration(
                        color: fondoAcento,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: primarioOscuro, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SEREO',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Acompañamiento psicológico universitario',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: textoSecundario),
                  ),
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
                    decoration: const InputDecoration(
                      hintText: 'nombre@ucundinamarca.edu.co',
                    ),
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
                        onPressed: () =>
                            setState(() => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                    onSubmitted: (_) => _iniciarSesion(),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _cargando ? null : () {},
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: primarioOscuro, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                  const SizedBox(height: 16),

                  const Text(
                    'Solo se permite el ingreso con correo institucional. '
                    'Si no eres estudiante activo, contacta a Bienestar.',
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