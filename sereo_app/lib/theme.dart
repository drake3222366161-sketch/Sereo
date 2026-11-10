import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primario = Color(0xFF1D9E75);
const primarioOscuro = Color(0xFF0F6E56);
const primarioMuyOscuro = Color(0xFF04342C);
const fondoAcento = Color(0xFFE1F5EE);
const textoSecundario = Color(0xFF5F5E5A);
const textoMuted = Color(0xFF888780);

// Acento cálido para el botón de SOS: una terracota suave en vez de un
// rojo puro. Transmite urgencia sin resultar agresiva, y combina con el
// verde-azulado de la marca (son tonos casi complementarios).
const colorSos = Color(0xFFE0684A);

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

// =====================================================
// Paleta estandarizada de estados (SOS y Citas)
// Un solo lugar para que ambos módulos usen exactamente los mismos
// colores, en vez de tonos sueltos que no combinan entre sí.
// =====================================================

/// Color de fondo para el estado dado (usado en Chips, badges, etc.)
Color colorEstado(String estado) {
  switch (estado) {
    case 'pendiente':
      return const Color(0xFFD98324); // naranja-dorado cálido, claramente distinto al verde de marca
    case 'en_proceso':
    case 'confirmada':
      return primarioOscuro; // el verde-azulado de la marca
    case 'reagendada':
      return const Color(0xFF8C6FC4); // violeta más vivo, se distingue bien del verde
    case 'atendida':
      return const Color(0xFF3FA34D); // verde césped, distinto en tono al verde-azulado de marca
    case 'cancelada':
      return const Color(0xFF9E9E9E); // gris neutro
    default:
      return const Color(0xFF9E9E9E);
  }
}

/// Texto legible en español para cada estado
String textoEstado(String estado) {
  switch (estado) {
    case 'pendiente':
      return 'Pendiente';
    case 'en_proceso':
      return 'En proceso';
    case 'confirmada':
      return 'Confirmada';
    case 'reagendada':
      return 'Reagendada';
    case 'atendida':
      return 'Atendida';
    case 'cancelada':
      return 'Cancelada';
    default:
      return estado;
  }
}
