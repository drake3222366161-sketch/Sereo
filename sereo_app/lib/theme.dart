import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primario = Color(0xFF1D9E75);
const primarioOscuro = Color(0xFF0F6E56);
const primarioMuyOscuro = Color(0xFF04342C);
const fondoAcento = Color(0xFFE1F5EE);
const textoSecundario = Color(0xFF5F5E5A);
const textoMuted = Color(0xFF888780);

// Controlador global y muy simple del tema. Es un ValueNotifier: cualquier
// widget que lo "escuche" (con ValueListenableBuilder) se redibuja solo
// cuando su valor cambia - no necesitamos un paquete de manejo de estado
// más complejo para algo tan puntual como esto.
final ValueNotifier<ThemeMode> temaActual = ValueNotifier(ThemeMode.light);

const _clavePreferenciaTema = 'tema_oscuro';

/// Se llama una sola vez, al arrancar la app, para cargar la preferencia
/// guardada la última vez que la persona usó la app.
Future<void> cargarTemaGuardado() async {
  final prefs = await SharedPreferences.getInstance();
  final esOscuro = prefs.getBool(_clavePreferenciaTema) ?? false;
  temaActual.value = esOscuro ? ThemeMode.dark : ThemeMode.light;
}

/// Cambia el tema y guarda la preferencia para la próxima vez.
Future<void> alternarTema() async {
  final nuevoModo = temaActual.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  temaActual.value = nuevoModo;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_clavePreferenciaTema, nuevoModo == ThemeMode.dark);
}

ThemeData sereoThemeClaro() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAF8),
    colorScheme: ColorScheme.fromSeed(seedColor: primario, brightness: Brightness.light),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

ThemeData sereoThemeOscuro() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(seedColor: primario, brightness: Brightness.dark),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
