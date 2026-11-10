import 'package:flutter/material.dart';
import 'locale_controller.dart';

/// Botón de idioma reutilizable. Ponlo en el 'actions' del AppBar de
/// cualquier pantalla:  actions: const [LanguageButton()],
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: 'Idioma / Language',
      onSelected: (codigo) => cambiarIdioma(codigo),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'es', child: Text('Español')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
    );
  }
}
