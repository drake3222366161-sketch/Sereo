import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'theme.dart';

class CitasEstudianteScreen extends StatefulWidget {
  final int estudianteId;

  const CitasEstudianteScreen({super.key, required this.estudianteId});

  @override
  State<CitasEstudianteScreen> createState() => _CitasEstudianteScreenState();
}

class _CitasEstudianteScreenState extends State<CitasEstudianteScreen> {
  List<dynamic> _franjasLibres = [];
  List<dynamic> _misCitas = [];
  bool _cargando = true;
  DateTime _diaSeleccionado = DateTime.now();
  DateTime _mesEnfocado = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    await Future.wait([_cargarFranjas(), _cargarMisCitas()]);
    setState(() => _cargando = false);
  }

  Future<void> _cargarFranjas() async {
    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/disponibilidad_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'modo': 'libres'}),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _franjasLibres = datos['franjas'] ?? []);
    } catch (e) {
      // deja como estaba
    }
  }

  Future<void> _cargarMisCitas() async {
    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/citas_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rol': 'estudiante', 'estudiante_id': widget.estudianteId}),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _misCitas = datos['citas'] ?? []);
    } catch (e) {
      // deja como estaba
    }
  }

  String _soloFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<dynamic> _franjasDelDia(DateTime dia) {
    final fechaTexto = _soloFecha(dia);
    return _franjasLibres.where((f) => f['fecha'] == fechaTexto).toList();
  }

  Future<void> _reservar(dynamic franja) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar cita'),
        content: Text(
          'Vas a solicitar una cita con ${franja['profesional_nombre']}\n'
          '${franja['fecha']} a las ${franja['hora_inicio']}.\n\n'
          'Bienestar deberá confirmarla.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Solicitar')),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/citas_crear.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estudiante_id': widget.estudianteId,
          'profesional_id': franja['profesional_id'],
          'fecha': franja['fecha'],
          'hora': franja['hora_inicio'],
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(datos['mensaje'])));
      await _cargarTodo();
    } catch (e) {
      // silencioso
    }
  }

  Future<void> _cancelarCita(int citaId) async {
    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/citas_actualizar_estado.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cita_id': citaId,
          'accion': 'cancelar',
          'usuario_id': widget.estudianteId,
        }),
      );
      if (respuesta.statusCode == 200) {
        await _cargarTodo();
      }
    } catch (e) {
      // silencioso
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return const Color(0xFFB98900);
      case 'confirmada':
        return primarioOscuro;
      case 'reagendada':
        return Colors.deepPurple;
      case 'atendida':
        return const Color(0xFF2E7D32);
      case 'cancelada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final franjasHoy = _franjasDelDia(_diaSeleccionado);

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar cita')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarTodo,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TableCalendar(
                    locale: 'es_ES',
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 180)),
                    focusedDay: _mesEnfocado,
                    selectedDayPredicate: (day) => isSameDay(day, _diaSeleccionado),
                    onDaySelected: (seleccionado, enfocado) {
                      setState(() {
                        _diaSeleccionado = seleccionado;
                        _mesEnfocado = enfocado;
                      });
                    },
                    eventLoader: (day) => _franjasDelDia(day),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(color: fondoAcento, shape: BoxShape.circle),
                      selectedDecoration: BoxDecoration(color: primario, shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: primarioOscuro, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Horarios disponibles - ${_soloFecha(_diaSeleccionado)}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 10),

                  if (franjasHoy.isEmpty)
                    const Text('No hay horarios libres este día.',
                        style: TextStyle(color: textoSecundario)),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in franjasHoy)
                        ActionChip(
                          avatar: const Icon(Icons.schedule, size: 16),
                          label: Text('${f['hora_inicio']} · ${f['profesional_nombre']}'),
                          onPressed: () => _reservar(f),
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  const Text('Mis citas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 10),

                  if (_misCitas.isEmpty)
                    const Text('Aún no tienes citas agendadas.', style: TextStyle(color: textoSecundario)),

                  for (final c in _misCitas)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(c['profesional_nombre'] ?? 'Por asignar'),
                        subtitle: Text(c['fecha_hora']),
                        trailing: (c['estado'] == 'pendiente' || c['estado'] == 'confirmada')
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(c['estado'],
                                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                                    backgroundColor: _colorEstado(c['estado']),
                                    padding: EdgeInsets.zero,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => _cancelarCita(c['id']),
                                  ),
                                ],
                              )
                            : Chip(
                                label: Text(c['estado'],
                                    style: const TextStyle(color: Colors.white, fontSize: 11)),
                                backgroundColor: _colorEstado(c['estado']),
                              ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
