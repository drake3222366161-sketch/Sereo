import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await cargarTemaGuardado(); // lee la preferencia de tema guardada, si existe
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder reconstruye SOLO este widget (MaterialApp)
    // cada vez que 'temaActual' cambia de valor - así el cambio de tema
    // se refleja en toda la app al instante, sin tener que reiniciarla.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaActual,
      builder: (context, modo, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SEREO',
          theme: sereoThemeClaro(),
          darkTheme: sereoThemeOscuro(),
          themeMode: modo,
          home: const LoginScreen(),
        );
      },
    );
  }
}
