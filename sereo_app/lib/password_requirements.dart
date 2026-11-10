import 'package:flutter/material.dart';
import 'package:sereo_app/l10n_ext.dart';

/// Reglas de la política de contraseñas (espejo de password_policy.php).
/// La validación definitiva siempre la hace el servidor; esto es ayuda visual
/// y evita una petición innecesaria.
class PasswordRules {
  static const int minLength = 10;

  static bool tieneLongitud(String p) => p.runes.length >= minLength;
  static bool tieneMayuscula(String p) => RegExp(r'\p{Lu}', unicode: true).hasMatch(p);
  static bool tieneMinuscula(String p) => RegExp(r'\p{Ll}', unicode: true).hasMatch(p);
  static bool tieneNumero(String p) => RegExp(r'\d').hasMatch(p);
  static bool tieneEspecial(String p) =>
      RegExp(r'[^\p{L}\p{N}\s]', unicode: true).hasMatch(p);

  static bool cumpleTodo(String p) =>
      tieneLongitud(p) &&
      tieneMayuscula(p) &&
      tieneMinuscula(p) &&
      tieneNumero(p) &&
      tieneEspecial(p);
}

/// Checklist en vivo: cada requisito se marca en verde cuando se cumple.
class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({super.key, required this.password});

  Widget _fila(String texto, bool cumple) {
    final color = cumple ? const Color(0xFF0F6E56) : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(texto, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.passwordReqTitle,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          _fila(t.passwordReqLength, PasswordRules.tieneLongitud(password)),
          _fila(t.passwordReqUpper, PasswordRules.tieneMayuscula(password)),
          _fila(t.passwordReqLower, PasswordRules.tieneMinuscula(password)),
          _fila(t.passwordReqNumber, PasswordRules.tieneNumero(password)),
          _fila(t.passwordReqSpecial, PasswordRules.tieneEspecial(password)),
        ],
      ),
    );
  }
}

/// Convierte la respuesta de error del servidor (codigo: 'password_policy')
/// en un mensaje en el idioma actual de la app.
String mensajeErrorContrasena(BuildContext context, dynamic datos) {
  final t = context.t;
  final fallos = (datos['requisitos_fallidos'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      <String>[];

  final lineas = <String>[t.passwordPolicyError];
  if (fallos.contains('datos_personales')) lineas.add(t.passwordErrPersonal);
  if (fallos.contains('comun')) lineas.add(t.passwordErrCommon);
  return lineas.join('\n');
}
