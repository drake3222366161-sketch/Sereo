import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sereo_app/l10n/app_localizations.dart';
import 'api_config.dart';
import 'theme.dart';
import 'register_screen.dart';
import 'politica_screen.dart';
import 'inactivity_guard.dart';
import 'captcha_widget.dart';
import 'home_estudiante.dart';
import 'home_staff.dart';
import 'language_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _captchaKey = GlobalKey<CaptchaWidgetState>();
  bool _ocultarContrasena = true;
  bool _cargando = false;
  String? _error;

  String _correoCompleto() {
    final texto = _correoController.text.trim();
    if (texto.contains('@')) return texto;
    return '$texto@ucundinamarca.edu.co';
  }

  Future<void> _iniciarSesion() async {
    // Se toma 't' antes de cualquier 'await' para no usar el context después.
    final t = AppLocalizations.of(context)!;

    setState(() {
      _cargando = true;
      _error = null;
    });

    if (!_captchaKey.currentState!.validar()) {
      setState(() {
        _error = t.err_captcha;
        _cargando = false;
      });
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/login.php');

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _correoCompleto(),
          'contrasena': _contrasenaController.text,
        }),
      );

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        // OJO: este mensaje viene del PHP, así que sigue en español.
        // Más adelante se cambia para que el PHP mande un código.
        setState(() => _error = datos['error']);
        return;
      }

      _procesarUsuario(datos['usuario']);
    } catch (e) {
      setState(() => _error = t.err_connection(e.toString()));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _procesarUsuario(Map<String, dynamic> usuario) {
    if (!mounted) return;

    final rol = usuario['rol'];
    final id = usuario['id'] is int ? usuario['id'] : int.parse(usuario['id'].toString());
    final politicaAceptada = usuario['politica_aceptada'] == true;

    void irAHome(BuildContext ctx) => _navegarSegunRol(ctx, usuario, rol, id);

    if (!politicaAceptada) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PoliticaScreen(usuarioId: id, alContinuar: irAHome),
        ),
      );
    } else {
      irAHome(context);
    }
  }

  void _navegarSegunRol(BuildContext ctx, Map<String, dynamic> usuario, String rol, int id) {
    final correo = usuario['correo'] as String;
    final token = usuario['token_sesion'] as String;

    if (rol == 'estudiante') {
      Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InactivityGuard(
            usuarioId: id,
            correo: correo,
            tokenSesion: token,
            child: HomeEstudiante(
              estudianteId: id,
              nombreEstudiante: usuario['nombre'],
              programaAcademico: usuario['programa_academico'],
            ),
          ),
        ),
      );
    } else {
      Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(
          builder: (_) => InactivityGuard(
            usuarioId: id,
            correo: correo,
            tokenSesion: token,
            child: HomeStaff(
              usuarioId: id,
              nombreUsuario: usuario['nombre'],
              rol: rol,
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        // Stack: el formulario ocupa todo y el botón de idioma flota
        // en la esquina superior derecha.
        child: Stack(
          children: [
            Center(
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
                      Text(t.appSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: textoSecundario)),
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

                      Text(t.institutionalEmail,
                          style: const TextStyle(fontSize: 12, color: textoSecundario)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: t.emailHint,
                          suffixText: '@ucundinamarca.edu.co',
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(t.password,
                          style: const TextStyle(fontSize: 12, color: textoSecundario)),
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
                      const SizedBox(height: 16),
                      CaptchaWidget(key: _captchaKey),
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
                            : Text(t.login),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.noAccount, style: const TextStyle(fontSize: 13)),
                          TextButton(
                            onPressed: _cargando
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    );
                                  },
                            child: Text(t.signUpLink,
                                style: const TextStyle(
                                    color: primarioOscuro, fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text(
                        t.studentsOnlyNote,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: textoMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón de cambio de idioma (esquina superior derecha)
            const Positioned(
              top: 4,
              right: 8,
              child: LanguageButton(),
            ),
          ],
        ),
      ),
    );
  }
}
