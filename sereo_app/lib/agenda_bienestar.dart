import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'api_config.dart';
import 'theme.dart';
import 'package:sereo_app/l10n_ext.dart';
import 'nivel_texto.dart';

class AgendaBienestarScreen extends StatefulWidget {
  final int profesionalId;

  const AgendaBienestarScreen({super.key, required this.profesionalId});

  @override
  State<AgendaBienestarScreen> createState() => _AgendaBienestarScreenState();
}

class _AgendaBienestarScreenState extends State<AgendaBienestarScreen> {
  List<dynamic> _franjas = [];
  List<dynamic> _citas = [];
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
    await Future.wait([_cargarFranjas(), _cargarCitas()]);
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cargarFranjas() async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disponibilidad_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'modo': 'propias', 'profesional_id': widget.profesionalId}),
      );
      final datos = jsonDecode(respuesta.body);
      if (mounted) setState(() => _franjas = datos['franjas'] ?? []);
    } catch (e) {
      // deja como estaba
    }
  }

  Future<void> _cargarCitas() async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/citas_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rol': 'bienestar', 'profesional_id': widget.profesionalId}),
      );
      final datos = jsonDecode(respuesta.body);
      if (mounted) setState(() => _citas = datos['citas'] ?? []);
    } catch (e) {
      // deja como estaba
    }
  }

  String _soloFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<dynamic> _franjasDelDia(DateTime dia) {
    final fechaTexto = _soloFecha(dia);
    return _franjas.where((f) => f['fecha'] == fechaTexto).toList();
  }

  List<dynamic> _citasDelDia(DateTime dia) {
    final fechaTexto = _soloFecha(dia);
    return _citas.where((c) => (c['fecha_hora'] as String).startsWith(fechaTexto)).toList();
  }

  bool _diaTieneEventos(DateTime dia) {
    return _franjasDelDia(dia).isNotEmpty || _citasDelDia(dia).isNotEmpty;
  }

  // ---------- Acciones sobre disponibilidad ----------

  Future<void> _agregarFranja() async {
    final horaInicio = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input, // escribir la hora, no reloj
      helpText: context.t.agendaBienestarHoraDeInicio,
    );
    if (horaInicio == null || !mounted) return;

    final horaFin = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      helpText: context.t.agendaBienestarHoraDeFin,
    );
    if (horaFin == null) return;

    final fechaTexto = _soloFecha(_diaSeleccionado);
    final inicioTexto = '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';
    final finTexto = '${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disponibilidad_crear.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'profesional_id': widget.profesionalId,
          'fecha': fechaTexto,
          'hora_inicio': inicioTexto,
          'hora_fin': finTexto,
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (!mounted) return;
      if (respuesta.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        return;
      }
      await _cargarFranjas();
    } catch (e) {
      // silencioso
    }
  }

  Future<void> _desactivarFranja(int id, String fecha, String horaInicio, String horaFin) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.t.agendaBienestarDesactivarEstaFranja),
        content: Text(
          context.t.agendaBienestarVasADesactivarLa(fecha, horaInicio, horaFin),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t.agendaBienestarCancelar)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorSos, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.t.agendaBienestarSiDesactivar),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disponibilidad_eliminar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'profesional_id': widget.profesionalId}),
      );
      final datos = jsonDecode(respuesta.body);
      if (!mounted) return;
      if (respuesta.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        return;
      }
      await _cargarFranjas();
    } catch (e) {
      // silencioso
    }
  }

  // ---------- Acciones sobre citas ----------

  Future<void> _accionCita(int citaId, String accion, {String? nuevaFecha, String? nuevaHora}) async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/citas_actualizar_estado.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'cita_id': citaId,
          'accion': accion,
          'usuario_id': widget.profesionalId,
          if (nuevaFecha != null) 'nueva_fecha': nuevaFecha,
          if (nuevaHora != null) 'nueva_hora': nuevaHora,
        }),
      );
      final datos = jsonDecode(respuesta.body);
      if (!mounted) return;
      if (respuesta.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        return;
      }
      await _cargarCitas();
    } catch (e) {
      // silencioso
    }
  }

  Future<void> _confirmarYCancelarCita(int citaId, String estudianteNombre, String fechaHora) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.t.agendaBienestarCancelarEstaCita),
        content: Text(context.t.agendaBienestarVasACancelarLa(estudianteNombre, fechaHora)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t.agendaBienestarNoVolver)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorSos, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.t.agendaBienestarSiCancelar),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _accionCita(citaId, 'cancelar');
    }
  }

  Future<void> _reagendarCita(int citaId) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (hora == null) return;

    final fechaTexto = _soloFecha(fecha);
    final horaTexto = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

    await _accionCita(citaId, 'reagendar', nuevaFecha: fechaTexto, nuevaHora: horaTexto);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    final franjasHoy = _franjasDelDia(_diaSeleccionado);
    final citasHoy = _citasDelDia(_diaSeleccionado);

    return RefreshIndicator(
      onRefresh: _cargarTodo,
      child: ListView(
        children: [
          TableCalendar(
            locale: Localizations.localeOf(context).toString(),
            availableCalendarFormats: {
              CalendarFormat.month: context.t.calendarioMes,
              CalendarFormat.twoWeeks: context.t.calendarioDosSemanas,
              CalendarFormat.week: context.t.calendarioSemana,
            },
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 180)),
            focusedDay: _mesEnfocado,
            selectedDayPredicate: (day) => isSameDay(day, _diaSeleccionado),
            onDaySelected: (seleccionado, enfocado) {
              setState(() {
                _diaSeleccionado = seleccionado;
                _mesEnfocado = enfocado;
              });
            },
            eventLoader: (day) => _diaTieneEventos(day) ? [true] : [],
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: fondoAcento, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: primario, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: primarioOscuro, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.t.agendaBienestarDisponibilidadFecha(_soloFecha(_diaSeleccionado)),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.t.agendaBienestarAgregar),
                  onPressed: _agregarFranja,
                ),
              ],
            ),
          ),

          if (franjasHoy.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.t.agendaBienestarNoHasDefinidoDisponibilidad,
                  style: TextStyle(color: textoSecundario, fontSize: 13)),
            ),

          for (final f in franjasHoy)
            Builder(builder: (context) {
              final activa = f['disponible'] == 1 || f['disponible'] == true;
              return ListTile(
                dense: true,
                leading: Icon(activa ? Icons.event_available : Icons.event_busy,
                    color: activa ? primarioOscuro : Colors.grey, size: 20),
                title: Text(
                  '${f['hora_inicio']} - ${f['hora_fin']}',
                  style: activa ? null : const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
                ),
                trailing: activa
                    ? IconButton(
                        tooltip: context.t.agendaBienestarDesactivar,
                        icon: const Icon(Icons.visibility_off_outlined, size: 18),
                        onPressed: () => _desactivarFranja(
                            f['id'], f['fecha'], f['hora_inicio'], f['hora_fin']),
                      )
                    : null,
              );
            }),

          const Divider(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(context.t.agendaBienestarCitasFecha(_soloFecha(_diaSeleccionado)),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          const SizedBox(height: 8),

          if (citasHoy.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(context.t.agendaBienestarNoTienesCitasEste,
                  style: TextStyle(color: textoSecundario, fontSize: 13)),
            ),

          for (final c in citasHoy)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(c['estudiante_nombre'],
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Chip(
                          label: Text(textoEstadoL10n(context, c['estado']),
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: colorEstado(c['estado']),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    Text(c['fecha_hora'], style: const TextStyle(fontSize: 12, color: textoSecundario)),
                    if (c['motivo'] != null)
                      Text(context.t.citaMotivo(c['motivo']), style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (c['estado'] == 'pendiente')
                          ElevatedButton(
                            onPressed: () => _accionCita(c['id'], 'confirmar'),
                            child: Text(context.t.agendaBienestarConfirmar),
                          ),
                        if (c['estado'] == 'confirmada')
                          ElevatedButton(
                            onPressed: () => _accionCita(c['id'], 'atendida'),
                            child: Text(context.t.agendaBienestarMarcarAtendida),
                          ),
                        if (c['estado'] == 'pendiente' || c['estado'] == 'confirmada') ...[
                          OutlinedButton(
                            onPressed: () => _reagendarCita(c['id']),
                            child: Text(context.t.agendaBienestarReagendar),
                          ),
                          OutlinedButton(
                            onPressed: () => _confirmarYCancelarCita(
                                c['id'], c['estudiante_nombre'], c['fecha_hora']),
                            child: Text(context.t.agendaBienestarCancelar),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
