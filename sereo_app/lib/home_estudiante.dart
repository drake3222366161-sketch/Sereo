import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_screen.dart';
import 'sos_estudiante.dart';
import 'citas_estudiante.dart';

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
      SnackBar(content: Text('$modulo — módulo en construcción')),
    );
  }

  void _cerrarSesion(BuildContext context) {
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
                        Text('Hola, $nombreEstudiante',
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
                    tooltip: 'Cerrar sesión',
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
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Solicitud prioritaria (SOS)',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onErrorContainer)),
                            Text('Si necesitas ayuda urgente',
                                style: TextStyle(
                                    fontSize: 12, color: Theme.of(context).colorScheme.onErrorContainer)),
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
                      titulo: 'Autoevaluación',
                      onTap: () => _proximamente(context, 'Autoevaluación'),
                    ),
                    _TarjetaModulo(
                      icono: Icons.calendar_month_outlined,
                      titulo: 'Mis citas',
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
                      titulo: 'Diario emocional',
                      onTap: () => _proximamente(context, 'Diario emocional'),
                    ),
                    _TarjetaModulo(
                      icono: Icons.account_circle_outlined,
                      titulo: 'Mi perfil',
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
          // Antes esto era 'Colors.white' fijo - en modo oscuro se veía
          // como un cuadro blanco encima de un fondo oscuro. Usando el
          // color que el propio tema define, se adapta automáticamente.
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
