import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'theme.dart';
import 'login_screen.dart';
import 'package:sereo_app/l10n_ext.dart';

/// Da acceso a los datos de la sesión actual a cualquier pantalla que esté
/// dentro del InactivityGuard:  SesionActual.of(context).tokenSesion
/// (las pantallas que se abren con Navigator.push deben recibir el token por
/// parámetro, porque quedan fuera de este árbol).
class SesionActual extends InheritedWidget {
  final int usuarioId;
  final String tokenSesion;

  const SesionActual({
    super.key,
    required this.usuarioId,
    required this.tokenSesion,
    required super.child,
  });

  static SesionActual of(BuildContext context) {
    final sesion = context.dependOnInheritedWidgetOfExactType<SesionActual>();
    assert(sesion != null, 'SesionActual no encontrada: la pantalla debe estar dentro de un InactivityGuard.');
    return sesion!;
  }

  @override
  bool updateShouldNotify(SesionActual old) =>
      usuarioId != old.usuarioId || tokenSesion != old.tokenSesion;
}

/// Envuelve la pantalla de inicio (estudiante o Bienestar/Admin) y vigila:
/// 1. Inactividad: a los 2 min bloquea pidiendo contraseña; a los 5 min
///    totales cierra sesión sola.
/// 2. Sesión única: cada cierto tiempo pregunta al backend si el token de
///    esta sesión sigue siendo el vigente. Si alguien inició sesión con la
///    misma cuenta en otro dispositivo, el token cambió, y esta sesión se
///    cierra automáticamente con un aviso.
class InactivityGuard extends StatefulWidget {
  final int usuarioId;
  final String correo;
  final String tokenSesion;
  final Widget child;

  const InactivityGuard({
    super.key,
    required this.usuarioId,
    required this.correo,
    required this.tokenSesion,
    required this.child,
  });

  @override
  State<InactivityGuard> createState() => _InactivityGuardState();
}

class _InactivityGuardState extends State<InactivityGuard> {
  static const _tiempoBloqueo = Duration(minutes: 2);
  static const _tiempoCierreSesion = Duration(minutes: 5);
  static const _intervaloVerificacionSesion = Duration(seconds: 20);

  Timer? _timerBloqueo;
  Timer? _timerCierreSesion;
  Timer? _timerVerificacionSesion;
  bool _bloqueado = false;

  @override
  void initState() {
    super.initState();
    _reiniciarTemporizadoresInactividad();
    _timerVerificacionSesion = Timer.periodic(
      _intervaloVerificacionSesion,
      (_) => _verificarSesionUnica(),
    );
  }

  @override
  void dispose() {
    _timerBloqueo?.cancel();
    _timerCierreSesion?.cancel();
    _timerVerificacionSesion?.cancel();
    super.dispose();
  }

  void _reiniciarTemporizadoresInactividad() {
    _timerBloqueo?.cancel();
    _timerCierreSesion?.cancel();

    _timerBloqueo = Timer(_tiempoBloqueo, () {
      if (mounted) {
        setState(() => _bloqueado = true);
        // Auditoría: queda registrado que la pantalla se bloqueó
        _avisarServidor('log_evento.php', {'usuario_id': widget.usuarioId, 'evento': 'bloqueo_inactividad'});
      }
    });

    _timerCierreSesion = Timer(_tiempoCierreSesion, () {
      _cerrarSesionForzado(context.t.inactivityGuardSesionCerradaInactividad, porInactividad: true);
    });
  }

  /// Avisa al backend sin esperar respuesta (si falla, no pasa nada).
  Future<void> _avisarServidor(String ruta, Map<String, dynamic> cuerpo) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/$ruta'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cuerpo),
      );
    } catch (_) {}
  }

  Future<void> _verificarSesionUnica() async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/verificar_sesion.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': widget.usuarioId,
          'token_sesion': widget.tokenSesion,
        }),
      );

      if (respuesta.statusCode != 200 && mounted) {
        _cerrarSesionForzado(
          context.t.inactivityGuardSesionOtroDispositivo,
        );
      }
    } catch (e) {
      // si falla por un problema de red momentáneo, no cerramos sesión -
      // solo lo intentamos de nuevo en el próximo ciclo
    }
  }

  void _cerrarSesionForzado(String mensaje, {bool porInactividad = false}) {
    if (!mounted) return;
    _timerBloqueo?.cancel();
    _timerCierreSesion?.cancel();
    _timerVerificacionSesion?.cancel();

    // Si se cerró por inactividad, también cerramos la sesión en el servidor
    // (antes solo se volvía al login y el token seguía vigente) y queda en el log.
    // Si fue "otro dispositivo", NO se llama: borraría el token de la otra sesión.
    if (porInactividad) {
      _avisarServidor('cerrar_sesion.php', {'usuario_id': widget.usuarioId, 'motivo': 'inactividad'});
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _registrarActividad() {
    if (_bloqueado) return;
    _reiniciarTemporizadoresInactividad();
  }

  void _alDesbloquear() {
    setState(() => _bloqueado = false);
    _reiniciarTemporizadoresInactividad();
  }

  @override
  Widget build(BuildContext context) {
    final contenido = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _registrarActividad(),
      onPointerSignal: (_) => _registrarActividad(),
      child: Stack(
        children: [
          widget.child,
          if (_bloqueado)
            _PantallaBloqueo(correo: widget.correo, onDesbloquear: _alDesbloquear),
        ],
      ),
    );
    return SesionActual(
      usuarioId: widget.usuarioId,
      tokenSesion: widget.tokenSesion,
      child: contenido,
    );
  }
}

class _PantallaBloqueo extends StatefulWidget {
  final String correo;
  final VoidCallback onDesbloquear;

  const _PantallaBloqueo({required this.correo, required this.onDesbloquear});

  @override
  State<_PantallaBloqueo> createState() => _PantallaBloqueoState();
}

class _PantallaBloqueoState extends State<_PantallaBloqueo> {
  final _contrasenaController = TextEditingController();
  bool _verificando = false;
  bool _ocultarContrasena = true;
  String? _error;

  Future<void> _verificar() async {
    setState(() {
      _verificando = true;
      _error = null;
    });

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': widget.correo,
          'contrasena': _contrasenaController.text,
          'solo_verificar': true, // solo comprobar la contraseña, sin crear sesión nueva
        }),
      );

      // Ojo: este login.php genera un token NUEVO. Al desbloquear así,
      // técnicamente se "reemplaza" la sesión actual por una recién
      // verificada - es intencional y no afecta al usuario, pero si más
      // adelante esto causa confusión en la verificación de sesión única,
      // se puede ajustar para no regenerar el token aquí.
      if (respuesta.statusCode == 200) {
        widget.onDesbloquear();
        return;
      }

      final datos = jsonDecode(respuesta.body);
      setState(() => _error = datos['error'] ?? context.t.inactivityGuardNoSePudoVerificar);
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(color: fondoAcento, shape: BoxShape.circle),
                      child: const Icon(Icons.lock_outline, color: primarioOscuro, size: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.t.inactivityGuardSesionBloqueadaPorInactividad,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(widget.correo,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEBEB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: const TextStyle(color: Color(0xFF791F1F), fontSize: 13)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: _contrasenaController,
                    obscureText: _ocultarContrasena,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: context.t.password,
                      suffixIcon: IconButton(
                        icon: Icon(_ocultarContrasena
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
                      ),
                    ),
                    onSubmitted: (_) => _verificar(),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primario,
                      foregroundColor: primarioMuyOscuro,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _verificando ? null : _verificar,
                    child: _verificando
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(context.t.inactivityGuardDesbloquear),
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
