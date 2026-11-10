import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idioma actual de la app. Igual que 'temaActual', es un ValueNotifier:
/// cuando cambia, el MaterialApp se reconstruye y toda la app cambia de idioma.
final ValueNotifier<Locale> idiomaActual = ValueNotifier<Locale>(const Locale('es'));

/// Lee el idioma guardado (si existe). Se llama una vez en main().
Future<void> cargarIdiomaGuardado() async {
  final prefs = await SharedPreferences.getInstance();
  final codigo = prefs.getString('idioma');
  if (codigo == 'es' || codigo == 'en') {
    idiomaActual.value = Locale(codigo!);
  }
}

/// Cambia el idioma y lo guarda para la próxima vez que se abra la app.
Future<void> cambiarIdioma(String codigo) async {
  idiomaActual.value = Locale(codigo);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('idioma', codigo);
}
