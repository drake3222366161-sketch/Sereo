import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'login_screen.dart';
import 'sos_estudiante.dart';
import 'citas_estudiante.dart';
import 'autoevaluacion_estudiante.dart';
import 'api_config.dart';
import 'package:sereo_app/l10n_ext.dart';

class HomeEstudiante extends StatelessWidget {
  final int estudianteId;
  final String nombreEstudiante;
  final String? programaAcademico;

  const HomeEstudiante({
    super.key,
    required this.estudianteId,
    required this.nombreEstudiante,
    this.programaAcademico,
  });

  void _proximamente(BuildContext context, String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t.homeEstudianteModuloEnConstruccion(modulo))),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    // Liberamos el token en el backend (no es estrictamente necesario, ya
    // que un login nuevo lo sobrescribe de todas formas, pero así queda
    // explícito que "nadie" tiene sesión activa hasta el próximo login).
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cerrar_sesion.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': estudianteId}),
      );
    } catch (e) {
      // si falla por conexión, igual dejamos salir a la persona
    }

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _irASos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SosEstudianteScreen(
          estudianteId: estudianteId,
          nombreEstudiante: nombreEstudiante,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: fondoAcento, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline, color: primarioOscuro),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.t.homeEstudianteHola(nombreEstudiante),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        if (programaAcademico != null)
                          Text(programaAcademico!,
                              style: const TextStyle(fontSize: 12, color: textoSecundario)),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: temaActual,
                    builder: (context, modo, _) {
                      return IconButton(
                        tooltip: modo == ThemeMode.dark ? 'Tema claro' : 'Tema oscuro',
                        icon: Icon(modo == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                        onPressed: alternarTema,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: context.t.homeEstudianteCerrarSesion,
                    icon: const Icon(Icons.logout, color: textoSecundario),
                    onPressed: () => _cerrarSesion(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _irASos(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: colorSos, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colorSos),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.t.homeEstudianteSolicitudPrioritariaSos,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface)),
                            Text(context.t.homeEstudianteSiNecesitasAyudaUrgente,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _TarjetaModulo(
                      icono: Icons.checklist_rtl,
                      titulo: context.t.autoevaluacionEstudianteAutoevaluacion,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AutoevaluacionEstudianteScreen(estudianteId: estudianteId),
                          ),
                        );
                      },
                    ),
                    _TarjetaModulo(
                      icono: Icons.calendar_month_outlined,
                      titulo: context.t.citasEstudianteMisCitas,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CitasEstudianteScreen(estudianteId: estudianteId),
                          ),
                        );
                      },
                    ),
                    _TarjetaModulo(
                      icono: Icons.menu_book_outlined,
                      titulo: context.t.homeEstudianteDiarioEmocional,
                      onTap: () => _proximamente(context, 'Diario emocional'),
                    ),
                    _TarjetaModulo(
                      icono: Icons.account_circle_outlined,
                      titulo: context.t.homeEstudianteMiPerfil,
                      onTap: () => _proximamente(context, 'Perfil'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaModulo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  const _TarjetaModulo({required this.icono, required this.titulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: colores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colores.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: colores.primary, size: 26),
            const SizedBox(height: 6),
            Text(titulo, style: TextStyle(fontSize: 13, color: colores.onSurface)),
          ],
        ),
      ),
    );
  }
}
