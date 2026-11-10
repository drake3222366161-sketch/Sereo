import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'theme.dart';
import 'politica_screen.dart';
import 'inactivity_guard.dart';
import 'captcha_widget.dart';
import 'home_estudiante.dart';
import 'package:sereo_app/l10n_ext.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  final _captchaKey = GlobalKey<CaptchaWidgetState>();

  String? _programaSeleccionado;
  bool _ocultarContrasena = true;
  bool _cargando = false;
  String? _error;

  String _correoCompleto() {
    final texto = _correoController.text.trim();
    if (texto.contains('@')) return texto;
    return '$texto@ucundinamarca.edu.co';
  }

  Future<void> _registrar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    if (_programaSeleccionado == null) {
      setState(() {
        _error = 'Selecciona tu programa académico.';
        _cargando = false;
      });
      return;
    }

    if (!_captchaKey.currentState!.validar()) {
      setState(() {
        _error = 'La verificación no es correcta. Intenta de nuevo.';
        _cargando = false;
      });
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/registro.php');

    try {
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre_completo': _nombreController.text.trim(),
          'correo': _correoCompleto(),
          'programa_academico': _programaSeleccionado,
          'contrasena': _contrasenaController.text,
          'confirmar_contrasena': _confirmarController.text,
        }),
      );

      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        setState(() => _error = datos['error']);
        return;
      }

      if (!mounted) return;

      final usuario = datos['usuario'];
      final id = usuario['id'] is int ? usuario['id'] : int.parse(usuario['id'].toString());
      final token = usuario['token_sesion'] as String;
      final correo = usuario['correo'] as String;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PoliticaScreen(
            usuarioId: id,
            alContinuar: (ctx) {
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
            },
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(context.t.registerCrearCuentaDeEstudiante,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(context.t.registerRegistrateConTuCorreo,
                      style: TextStyle(fontSize: 13, color: textoSecundario)),
                  const SizedBox(height: 24),

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

                  Text(context.t.registerNombreCompleto,
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(hintText: context.t.registerAnaMariaGomez),
                  ),
                  const SizedBox(height: 16),

                  Text(context.t.institutionalEmail,
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: context.t.emailHint,
                      suffixText: '@ucundinamarca.edu.co',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(context.t.registerProgramaAcademico,
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _programaSeleccionado,
                    decoration: InputDecoration(hintText: context.t.registerSeleccionaTuPrograma),
                    items: [
                      DropdownMenuItem(
                          value: 'Administración de Empresas', child: Text(context.t.registerAdministracionDeEmpresas)),
                      DropdownMenuItem(value: 'Contaduría Pública', child: Text(context.t.registerContaduriaPublica)),
                      DropdownMenuItem(value: 'Zootecnia', child: Text(context.t.registerZootecnia)),
                      DropdownMenuItem(
                          value: 'Ingeniería de Sistemas y Computación',
                          child: Text(context.t.registerIngenieriaDeSistemasY)),
                      DropdownMenuItem(value: 'Ingeniería Electrónica', child: Text(context.t.registerIngenieriaElectronica)),
                      DropdownMenuItem(value: 'Ciencias Sociales', child: Text(context.t.registerCienciasSociales)),
                      DropdownMenuItem(value: 'Educación Física', child: Text(context.t.registerEducacionFisica)),
                    ],
                    onChanged: (valor) => setState(() => _programaSeleccionado = valor),
                  ),
                  const SizedBox(height: 16),

                  Text(context.t.password,
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _contrasenaController,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      hintText: context.t.registerMinimo8Caracteres,
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(context.t.registerConfirmarContrasena,
                      style: TextStyle(fontSize: 12, color: textoSecundario)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _confirmarController,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(hintText: context.t.registerRepiteTuContrasena),
                  ),
                  const SizedBox(height: 16),
                  CaptchaWidget(key: _captchaKey),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primario,
                      foregroundColor: primarioMuyOscuro,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _cargando ? null : _registrar,
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(context.t.registerCrearCuenta),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
