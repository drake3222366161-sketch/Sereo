import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'login_screen.dart';
import 'sos_bienestar.dart';
import 'agenda_bienestar.dart';
import 'autoevaluaciones_bienestar.dart';
import 'reportes_bienestar.dart';
import 'usuarios_admin.dart';
import 'backup_restore_admin.dart';
import 'api_config.dart';
import 'package:sereo_app/l10n_ext.dart';

const fondoSidebar = Color(0xFF04342C);
const verdeItemActivo = Color(0xFF0F6E56);
const verdeTextoInactivo = Color(0xFF9FE1CB);

class HomeStaff extends StatefulWidget {
  final int usuarioId;
  final String nombreUsuario;
  final String rol; // 'bienestar' | 'admin'

  const HomeStaff({
    super.key,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.rol,
  });

  @override
  State<HomeStaff> createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
  int _indiceSeleccionado = 0;

  bool _cargandoDashboard = true;
  int _sosPendientes = 0;
  int _citasHoy = 0;
  int _citasSemana = 0;
  int _totalEstudiantes = 0;
  int _totalBienestar = 0;
  int _totalAdmin = 0;

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    setState(() => _cargandoDashboard = true);

    try {
      if (widget.rol == 'bienestar') {
        final respuesta = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/dashboard_bienestar.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        );
        final datos = jsonDecode(respuesta.body);
        setState(() {
          _sosPendientes = datos['sos_pendientes'] ?? 0;
          _citasHoy = datos['citas_hoy'] ?? 0;
          _citasSemana = datos['citas_semana'] ?? 0;
        });
      } else {
        final respuesta = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/usuarios_listar.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({}),
        );
        final datos = jsonDecode(respuesta.body);
        final List<dynamic> usuarios = datos['usuarios'] ?? [];
        setState(() {
          _totalEstudiantes = usuarios.where((u) => u['rol'] == 'estudiante').length;
          _totalBienestar = usuarios.where((u) => u['rol'] == 'bienestar').length;
          _totalAdmin = usuarios.where((u) => u['rol'] == 'admin').length;
        });
      }
    } catch (e) {
      // el dashboard queda en 0 en vez de romper la pantalla
    } finally {
      if (mounted) setState(() => _cargandoDashboard = false);
    }
  }

  List<_ItemMenu> get _itemsMenu {
    if (widget.rol == 'admin') {
      return [
        _ItemMenu(icono: Icons.dashboard_outlined, titulo: context.t.homeStaffDashboard),
        _ItemMenu(icono: Icons.people_outline, titulo: context.t.homeStaffUsuarios),
        _ItemMenu(icono: Icons.settings_outlined, titulo: context.t.homeStaffConfiguracion),
      ];
    }
    return [
      _ItemMenu(icono: Icons.dashboard_outlined, titulo: context.t.homeStaffDashboard),
      _ItemMenu(icono: Icons.error_outline, titulo: context.t.homeStaffSolicitudes),
      _ItemMenu(icono: Icons.checklist_outlined, titulo: context.t.homeStaffAutoevaluaciones),
      _ItemMenu(icono: Icons.calendar_today_outlined, titulo: context.t.homeStaffAgenda),
      _ItemMenu(icono: Icons.bar_chart_outlined, titulo: context.t.homeStaffReportes),
    ];
  }

  Future<void> _cerrarSesion() async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cerrar_sesion.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': widget.usuarioId}),
      );
    } catch (e) {
      // si falla por conexión, igual dejamos salir a la persona
    }

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _contenidoPrincipal() {
    final tituloSeccion = _itemsMenu[_indiceSeleccionado].titulo;

    // Dashboard (índice 0 para ambos roles)
    if (_indiceSeleccionado == 0) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                IconButton(
                  tooltip: context.t.homeStaffActualizar,
                  icon: const Icon(Icons.refresh),
                  onPressed: _cargarDashboard,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _cargandoDashboard
                ? const Center(child: CircularProgressIndicator())
                : _panelDashboard(),
          ],
        ),
      );
    }

    // Solicitudes SOS: solo bienestar (índice 1)
    if (widget.rol == 'bienestar' && _indiceSeleccionado == 1) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(child: SosBienestarScreen(usuarioId: widget.usuarioId)),
          ],
        ),
      );
    }

    // Usuarios: solo admin (índice 1)
    if (widget.rol == 'admin' && _indiceSeleccionado == 1) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(child: UsuariosAdminScreen(adminId: widget.usuarioId)),
          ],
        ),
      );
    }

    // Configuración (backup/restauración): solo admin (índice 2)
    if (widget.rol == 'admin' && _indiceSeleccionado == 2) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(child: BackupRestoreAdminScreen(adminId: widget.usuarioId)),
          ],
        ),
      );
    }

    // Autoevaluaciones: solo bienestar (índice 2) - dato sensible
    if (widget.rol == 'bienestar' && _indiceSeleccionado == 2) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Expanded(child: AutoevaluacionesBienestarScreen()),
          ],
        ),
      );
    }

    // Agenda: calendario unificado - solo bienestar (índice 3)
    if (widget.rol == 'bienestar' && _indiceSeleccionado == 3) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Expanded(child: AgendaBienestarScreen(profesionalId: widget.usuarioId)),
          ],
        ),
      );
    }

    // Reportes: exportar CSV/PDF - solo bienestar (índice 4)
    if (widget.rol == 'bienestar' && _indiceSeleccionado == 4) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Expanded(child: ReportesBienestarScreen()),
          ],
        ),
      );
    }

    // Cualquier otro módulo, todavía sin construir
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tituloSeccion, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Text(context.t.homeStaffEsteModuloEstaEn,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: fondoSidebar,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(context.t.appName,
                      style: TextStyle(color: verdeTextoInactivo, fontWeight: FontWeight.w600, fontSize: 16)),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _itemsMenu.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: i == _indiceSeleccionado ? verdeItemActivo : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () {
                          setState(() => _indiceSeleccionado = i);
                          if (i == 0) _cargarDashboard();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Row(
                            children: [
                              Icon(_itemsMenu[i].icono,
                                  size: 18,
                                  color: i == _indiceSeleccionado ? Colors.white : verdeTextoInactivo),
                              const SizedBox(width: 10),
                              Text(_itemsMenu[i].titulo,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: i == _indiceSeleccionado ? Colors.white : verdeTextoInactivo,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const Spacer(),

                ValueListenableBuilder<ThemeMode>(
                  valueListenable: temaActual,
                  builder: (context, modo, _) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: alternarTema,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                modo == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                size: 18,
                                color: verdeTextoInactivo,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                modo == ThemeMode.dark ? 'Tema claro' : 'Tema oscuro',
                                style: const TextStyle(fontSize: 13, color: verdeTextoInactivo),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: _cerrarSesion,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: verdeTextoInactivo),
                          SizedBox(width: 10),
                          Text(context.t.homeEstudianteCerrarSesion, style: TextStyle(fontSize: 13, color: verdeTextoInactivo)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${widget.nombreUsuario}\n(${widget.rol})',
                    style: const TextStyle(fontSize: 11, color: verdeTextoInactivo),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: _contenidoPrincipal(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelDashboard() {
    if (widget.rol == 'bienestar') {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _tarjetaMetrica('Solicitudes pendientes', '$_sosPendientes', Icons.error_outline),
          _tarjetaMetrica('Citas de hoy', '$_citasHoy', Icons.today_outlined),
          _tarjetaMetrica('Citas esta semana', '$_citasSemana', Icons.calendar_view_week_outlined),
        ],
      );
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _tarjetaMetrica('Estudiantes', '$_totalEstudiantes', Icons.school_outlined),
        _tarjetaMetrica('Bienestar', '$_totalBienestar', Icons.favorite_outline),
        _tarjetaMetrica('Administradores', '$_totalAdmin', Icons.admin_panel_settings_outlined),
      ],
    );
  }

  Widget _tarjetaMetrica(String titulo, String valor, IconData icono) {
    final colores = Theme.of(context).colorScheme;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colores.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: colores.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(titulo, style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(valor,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colores.onSurface)),
        ],
      ),
    );
  }
}

class _ItemMenu {
  final IconData icono;
  final String titulo;
  const _ItemMenu({required this.icono, required this.titulo});
}
