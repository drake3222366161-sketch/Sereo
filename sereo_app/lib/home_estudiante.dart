import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_screen.dart';

class HomeEstudiante extends StatelessWidget {
  final String nombreEstudiante;
  final String? programaAcademico;

  const HomeEstudiante({
    super.key,
    required this.nombreEstudiante,
    this.programaAcademico,
  });

  void _proximamente(BuildContext context, String modulo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$modulo — módulo en construcción')),
    );
  }

  // Cierra sesión: como no guardamos ningún token, "cerrar sesión" aquí
  // significa simplemente regresar al login, quitando esta pantalla
  // (y cualquier otra) de la pila de navegación.
  void _cerrarSesion(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
                  IconButton(
                    tooltip: 'Cerrar sesión',
                    icon: const Icon(Icons.logout, color: textoSecundario),
                    onPressed: () => _cerrarSesion(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _proximamente(context, 'Solicitud prioritaria (SOS)'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCEBEB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFF791F1F)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Solicitud prioritaria (SOS)',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF791F1F))),
                            Text('Si necesitas ayuda urgente',
                                style: TextStyle(fontSize: 12, color: Color(0xFF791F1F))),
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
                      onTap: () => _proximamente(context, 'Citas'),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD3D1C7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: primarioOscuro, size: 26),
            const SizedBox(height: 6),
            Text(titulo, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
