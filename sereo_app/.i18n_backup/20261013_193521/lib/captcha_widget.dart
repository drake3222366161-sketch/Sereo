import 'dart:math';
import 'package:flutter/material.dart';

/// Un CAPTCHA propio y simple: una suma con números pequeños que la
/// persona debe resolver. No depende de ningún servicio externo (útil
/// porque la app también corre como escritorio nativo, sin navegador).
///
/// Uso: se coloca en el formulario con una GlobalKey, y antes de enviar
/// el formulario se llama a `key.currentState!.validar()`.
class CaptchaWidget extends StatefulWidget {
  const CaptchaWidget({super.key});

  @override
  State<CaptchaWidget> createState() => CaptchaWidgetState();
}

class CaptchaWidgetState extends State<CaptchaWidget> {
  final _random = Random();
  final _respuestaController = TextEditingController();

  late int _numeroA;
  late int _numeroB;

  @override
  void initState() {
    super.initState();
    _generarNuevaOperacion();
  }

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  void _generarNuevaOperacion() {
    _numeroA = _random.nextInt(9) + 1; // 1 a 9
    _numeroB = _random.nextInt(9) + 1;
    _respuestaController.clear();
  }

  /// Llamar justo antes de enviar el formulario. Si la respuesta es
  /// incorrecta, genera una operación nueva (para evitar que alguien
  /// simplemente siga intentando la misma) y devuelve false.
  bool validar() {
    final respuestaCorrecta = _numeroA + _numeroB;
    final respuestaUsuario = int.tryParse(_respuestaController.text.trim());

    final esValido = respuestaUsuario == respuestaCorrecta;
    if (!esValido) {
      setState(_generarNuevaOperacion);
    }
    return esValido;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$_numeroA + $_numeroB =',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _respuestaController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Otra operación',
            icon: Icon(Icons.refresh, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: () => setState(_generarNuevaOperacion),
          ),
        ],
      ),
    );
  }
}
