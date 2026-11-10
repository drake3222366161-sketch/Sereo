import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'theme.dart';
import 'password_requirements.dart';
import 'package:sereo_app/l10n_ext.dart';

// Mismos valores que el desplegable de register_screen.dart y que perfil_guardar.php
const _programasValidos = [
  'Administración de Empresas',
  'Contaduría Pública',
  'Zootecnia',
  'Ingeniería de Sistemas y Computación',
  'Ingeniería Electrónica',
  'Ciencias Sociales',
  'Educación Física',
];

String _etiquetaPrograma(BuildContext context, String valor) {
  final t = context.t;
  switch (valor) {
    case 'Administración de Empresas':
      return t.registerAdministracionDeEmpresas;
    case 'Contaduría Pública':
      return t.registerContaduriaPublica;
    case 'Zootecnia':
      return t.registerZootecnia;
    case 'Ingeniería de Sistemas y Computación':
      return t.registerIngenieriaDeSistemasY;
    case 'Ingeniería Electrónica':
      return t.registerIngenieriaElectronica;
    case 'Ciencias Sociales':
      return t.registerCienciasSociales;
    case 'Educación Física':
      return t.registerEducacionFisica;
    default:
      return valor;
  }
}

/// Convierte la respuesta de error del servidor (campo "codigo") en un mensaje
/// traducido al idioma actual de la app.
String _mensajePerfil(BuildContext context, dynamic datos) {
  final t = context.t;
  final codigo = datos is Map ? datos['codigo']?.toString() : null;
  switch (codigo) {
    case 'nombre_invalido':
      return t.perfilErrNombre;
    case 'programa_invalido':
      return t.perfilErrPrograma;
    case 'semestre_invalido':
      return t.perfilErrSemestre;
    case 'telefono_invalido':
    case 'contacto_telefono_invalido':
      return t.perfilErrTelefono;
    case 'contacto_incompleto':
      return t.perfilErrContactoIncompleto;
    case 'contacto_nombre_invalido':
      return t.perfilErrContactoNombre;
    case 'contrasena_actual_incorrecta':
      return t.perfilErrContrasenaActual;
    case 'no_coinciden':
      return t.perfilErrNoCoinciden;
    case 'igual_a_la_actual':
      return t.perfilErrIgualActual;
    case 'sesion_invalida':
    case 'cuenta_desactivada':
    case 'sin_permiso':
      return t.perfilErrSesion;
    case 'password_policy':
      return mensajeErrorContrasena(context, datos);
    default:
      return (datos is Map ? datos['error'] : null)?.toString() ?? 'Error';
  }
}

class PerfilEstudianteScreen extends StatefulWidget {
  final int estudianteId;
  final String tokenSesion;

  const PerfilEstudianteScreen({
    super.key,
    required this.estudianteId,
    required this.tokenSesion,
  });

  @override
  State<PerfilEstudianteScreen> createState() => _PerfilEstudianteScreenState();
}

class _PerfilEstudianteScreenState extends State<PerfilEstudianteScreen> {
  final _correoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _semestreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _contactoNombreCtrl = TextEditingController();
  final _contactoTelefonoCtrl = TextEditingController();

  String? _programa;
  String? _politicaFecha;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _nombreCtrl.dispose();
    _semestreCtrl.dispose();
    _telefonoCtrl.dispose();
    _contactoNombreCtrl.dispose();
    _contactoTelefonoCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _credenciales => {
        'usuario_id': widget.estudianteId,
        'token_sesion': widget.tokenSesion,
      };

  Future<void> _cargar() async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/perfil_obtener.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_credenciales),
      );
      final datos = jsonDecode(respuesta.body);
      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        setState(() => _error = _mensajePerfil(context, datos));
        return;
      }

      final p = datos['perfil'];
      setState(() {
        _correoCtrl.text = p['correo'] ?? '';
        _nombreCtrl.text = p['nombre_completo'] ?? '';
        _programa = p['programa_academico'];
        _semestreCtrl.text = p['semestre']?.toString() ?? '';
        _telefonoCtrl.text = p['telefono'] ?? '';
        _contactoNombreCtrl.text = p['contacto_emergencia_nombre'] ?? '';
        _contactoTelefonoCtrl.text = p['contacto_emergencia_telefono'] ?? '';
        final fecha = p['politica_aceptada_fecha'];
        _politicaFecha = (fecha is String && fecha.length >= 10) ? fecha.substring(0, 10) : null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = context.t.err_connection('$e'));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardar() async {
    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final semestreTexto = _semestreCtrl.text.trim();
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/perfil_guardar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ..._credenciales,
          'nombre_completo': _nombreCtrl.text.trim(),
          'programa_academico': _programa,
          'semestre': semestreTexto.isEmpty ? null : int.tryParse(semestreTexto),
          'telefono': _telefonoCtrl.text.trim(),
          'contacto_emergencia_nombre': _contactoNombreCtrl.text.trim(),
          'contacto_emergencia_telefono': _contactoTelefonoCtrl.text.trim(),
        }),
      );
      final datos = jsonDecode(respuesta.body);
      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        setState(() => _error = _mensajePerfil(context, datos));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.perfilGuardado)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = context.t.err_connection('$e'));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _abrirCambioContrasena() async {
    final cambiada = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogoCambiarContrasena(
        estudianteId: widget.estudianteId,
        tokenSesion: widget.tokenSesion,
      ),
    );
    if (cambiada == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.perfilContrasenaCambiada)),
      );
    }
  }

  String _iniciales() {
    final partes = _nombreCtrl.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    final segunda = partes.length > 1 ? partes[1][0] : '';
    return (partes.first[0] + segunda).toUpperCase();
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Text(texto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    // Si el programa guardado no está en la lista, lo conservamos como opción
    // para que el desplegable no falle.
    final programas = [
      ..._programasValidos,
      if (_programa != null && !_programasValidos.contains(_programa)) _programa!,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t.homeEstudianteMiPerfil)),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: fondoAcento,
                            child: Text(
                              _iniciales(),
                              style: const TextStyle(
                                  color: primarioOscuro, fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

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

                        _titulo(t.perfilDatosBasicos),
                        TextField(
                          controller: _nombreCtrl,
                          onChanged: (_) => setState(() {}),
                          inputFormatters: [LengthLimitingTextInputFormatter(150)],
                          decoration: InputDecoration(labelText: t.registerNombreCompleto),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _correoCtrl,
                          enabled: false,
                          decoration: InputDecoration(labelText: t.institutionalEmail),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _programa,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: t.registerProgramaAcademico),
                          items: [
                            for (final p in programas)
                              DropdownMenuItem(value: p, child: Text(_etiquetaPrograma(context, p))),
                          ],
                          onChanged: (valor) => setState(() => _programa = valor),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _semestreCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                decoration: InputDecoration(
                                    labelText: '${t.perfilSemestre} ${t.perfilOpcional}'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _telefonoCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                                decoration: InputDecoration(
                                    labelText: '${t.perfilTelefono} ${t.perfilOpcional}'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        _titulo(t.perfilContactoEmergencia),
                        TextField(
                          controller: _contactoNombreCtrl,
                          inputFormatters: [LengthLimitingTextInputFormatter(150)],
                          decoration: InputDecoration(
                              labelText: '${t.perfilContactoNombre} ${t.perfilOpcional}'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _contactoTelefonoCtrl,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [LengthLimitingTextInputFormatter(20)],
                          decoration: InputDecoration(
                              labelText: '${t.perfilContactoTelefono} ${t.perfilOpcional}'),
                        ),

                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primario,
                            foregroundColor: primarioMuyOscuro,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _guardando ? null : _guardar,
                          child: _guardando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(t.perfilGuardarCambios),
                        ),

                        const SizedBox(height: 28),
                        _titulo(t.perfilSeguridad),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.lock_outline, size: 18),
                          label: Text(t.perfilCambiarContrasena),
                          onPressed: _abrirCambioContrasena,
                        ),
                        if (_politicaFecha != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            t.perfilPoliticaAceptada(_politicaFecha!),
                            style: const TextStyle(fontSize: 12, color: textoSecundario),
                          ),
                        ],
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

class _DialogoCambiarContrasena extends StatefulWidget {
  final int estudianteId;
  final String tokenSesion;

  const _DialogoCambiarContrasena({required this.estudianteId, required this.tokenSesion});

  @override
  State<_DialogoCambiarContrasena> createState() => _DialogoCambiarContrasenaState();
}

class _DialogoCambiarContrasenaState extends State<_DialogoCambiarContrasena> {
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _ocultar = true;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final t = context.t;

    // Validaciones rápidas en el dispositivo; el servidor vuelve a validar todo.
    if (_actualCtrl.text.isEmpty) {
      setState(() => _error = t.perfilErrContrasenaActual);
      return;
    }
    if (!PasswordRules.cumpleTodo(_nuevaCtrl.text)) {
      setState(() => _error = t.passwordPolicyError);
      return;
    }
    if (_nuevaCtrl.text != _confirmarCtrl.text) {
      setState(() => _error = t.perfilErrNoCoinciden);
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cambiar_contrasena.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': widget.estudianteId,
          'token_sesion': widget.tokenSesion,
          'contrasena_actual': _actualCtrl.text,
          'contrasena_nueva': _nuevaCtrl.text,
          'confirmar_contrasena': _confirmarCtrl.text,
        }),
      );
      final datos = jsonDecode(respuesta.body);
      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        setState(() => _error = _mensajePerfil(context, datos));
        return;
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = context.t.err_connection('$e'));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.perfilCambiarContrasena),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _actualCtrl,
              obscureText: _ocultar,
              decoration: InputDecoration(labelText: t.perfilContrasenaActual),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nuevaCtrl,
              obscureText: _ocultar,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: t.perfilContrasenaNueva,
                suffixIcon: IconButton(
                  icon: Icon(_ocultar ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                ),
              ),
            ),
            PasswordRequirements(password: _nuevaCtrl.text),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmarCtrl,
              obscureText: _ocultar,
              decoration: InputDecoration(labelText: t.perfilConfirmarNueva),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: Text(t.agendaBienestarCancelar),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(t.usuariosAdminGuardar),
        ),
      ],
    );
  }
}
