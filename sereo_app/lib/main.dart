import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sereo_app/l10n/app_localizations.dart';
import 'theme.dart';
import 'login_screen.dart';
import 'locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('en', null);
  await cargarTemaGuardado(); // lee la preferencia de tema guardada, si existe
  await cargarIdiomaGuardado(); // lee el idioma guardado, si existe
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dos ValueListenableBuilder anidados: uno escucha el tema y el otro el
    // idioma. Si cualquiera de los dos cambia, el MaterialApp se reconstruye
    // y el cambio se ve en toda la app al instante.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaActual,
      builder: (context, modo, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: idiomaActual,
          builder: (context, idioma, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'SEREO',
              theme: sereoThemeClaro(),
              darkTheme: sereoThemeOscuro(),
              themeMode: modo,
              locale: idioma,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const LoginScreen(),
            );
          },
        );
      },
    );
  }
}