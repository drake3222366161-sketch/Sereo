import 'package:flutter/material.dart';

const primario = Color(0xFF1D9E75);
const primarioMuyOscuro = Color(0xFF04342C);
const fondoSidebar = Color(0xFF04342C);
const verdeItemActivo = Color(0xFF0F6E56);
const verdeTextoInactivo = Color(0xFF9FE1CB);

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final String rol; // 'bienestar' | 'admin'

  const HomeScreen({super.key, required this.nombreUsuario, required this.rol});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indiceSeleccionado = 0;

  List<_ItemMenu> get _itemsMenu {
    if (widget.rol == 'admin') {
      return const [
        _ItemMenu(icono: Icons.dashboard_outlined, titulo: 'Dashboard'),
        _ItemMenu(icono: Icons.people_outline, titulo: 'Usuarios'),
        _ItemMenu(icono: Icons.settings_outlined, titulo: 'Configuración'),
      ];
    }
    // Bienestar
    return const [
      _ItemMenu(icono: Icons.dashboard_outlined, titulo: 'Dashboard'),
      _ItemMenu(icono: Icons.error_outline, titulo: 'Solicitudes'),
      _ItemMenu(icono: Icons.calendar_today_outlined, titulo: 'Agenda'),
      _ItemMenu(icono: Icons.bar_chart_outlined, titulo: 'Reportes'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menú lateral
          Container(
            width: 200,
            color: fondoSidebar,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text('SEREO',
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
                        onTap: () => setState(() => _indiceSeleccionado = i),
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

          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_itemsMenu[_indiceSeleccionado].titulo,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  if (_indiceSeleccionado == 0) _panelDashboard(),
                  if (_indiceSeleccionado != 0)
                    const Expanded(
                      child: Center(
                        child: Text('Este módulo está en construcción',
                            style: TextStyle(color: Colors.black45)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelDashboard() {
    return Row(
      children: [
        _tarjetaMetrica('Solicitudes pendientes', '4'),
        const SizedBox(width: 12),
        _tarjetaMetrica('Citas de hoy', '6'),
      ],
    );
  }

  Widget _tarjetaMetrica(String titulo, String valor) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFE8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
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