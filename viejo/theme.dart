import 'package:flutter/material.dart';

const primario = Color(0xFF1D9E75);
const primarioOscuro = Color(0xFF0F6E56);
const primarioMuyOscuro = Color(0xFF04342C);
const fondoAcento = Color(0xFFE1F5EE);
const textoSecundario = Color(0xFF5F5E5A);
const textoMuted = Color(0xFF888780);

ThemeData sereoTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFAFAF8),
    colorScheme: ColorScheme.fromSeed(seedColor: primario),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
