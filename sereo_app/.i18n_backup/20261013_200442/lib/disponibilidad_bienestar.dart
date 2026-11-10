import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'package:sereo_app/l10n_ext.dart';

class DisponibilidadBienestarScreen extends StatefulWidget {
  final int profesionalId;

  const DisponibilidadBienestarScreen({super.key, required this.profesionalId});

  @override
  State<DisponibilidadBienestarScreen> createState() => _DisponibilidadBienestarScreenState();
}

class _DisponibilidadBienestarScreenState extends State<DisponibilidadBienestarScreen> {
  List<dynamic> _franjas = [];
  bool _cargando = true;
  String? _error;

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disponibilidad_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'modo': 'propias', 'profesional_id': widget.profesionalId}),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _franjas = datos['franjas'] ?? []);
    } catch (e) {
      // deja la lista como estaba
    } finally {
      setState(() => _cargando = false);
    }
  }

  String _formatoHora(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _agregarFranja() async {
    if (_fechaSeleccionada == null || _horaInicio == null || _horaFin == null) {
      setState(() => _error = 'Completa fecha, hora inicio y hora fin.');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final fechaTexto =
        '${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}';

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disponibilidad_crear.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'profesional_id': widget.profesionalId,
          'fecha': fechaTexto,
          'hora_inicio': _formatoHora(_horaInicio!),
          'hora_fin': _formatoHora(_horaFin!),
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        setState(() => _error = datos['error']);
        return;
      }

      setState(() {
        _fechaSeleccionada = null;
        _horaInicio = null;
        _horaFin = null;
      });
      await _cargar();
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      setState(() => _guardando = false);
    }
  }

  Future<void> _desactivarFranja(int id) async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disponibilidad_eliminar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'profesional_id': widget.profesionalId}),
      );
      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        }
        return;
      }
      await _cargar();
    } catch (e) {
      // silencioso
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.disponibilidadBienestarAgregarFranjaDeDisponibilidad,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),

          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_error!, style: const TextStyle(color: Color(0xFF791F1F), fontSize: 13)),
            ),
            const SizedBox(height: 10),
          ],

          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_fechaSeleccionada == null
                    ? 'Elegir fecha'
                    : '${_fechaSeleccionada!.year}-${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-${_fechaSeleccionada!.day.toString().padLeft(2, '0')}'),
                onPressed: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (fecha != null) setState(() => _fechaSeleccionada = fecha);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(_horaInicio == null ? 'Hora inicio' : _formatoHora(_horaInicio!)),
                onPressed: () async {
                  final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (hora != null) setState(() => _horaInicio = hora);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.access_time, size: 16),
                label: Text(_horaFin == null ? 'Hora fin' : _formatoHora(_horaFin!)),
                onPressed: () async {
                  final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (hora != null) setState(() => _horaFin = hora);
                },
              ),
              ElevatedButton(
                onPressed: _guardando ? null : _agregarFranja,
                child: _guardando
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(context.t.agendaBienestarAgregar),
              ),
            ],
          ),

          const SizedBox(height: 28),
          Text(context.t.disponibilidadBienestarMisFranjas, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),

          if (_cargando) const Center(child: CircularProgressIndicator()),

          if (!_cargando && _franjas.isEmpty)
            Text(context.t.disponibilidadBienestarAunNoHasAgregado, style: TextStyle(color: Colors.black54)),

          for (final f in _franjas)
            Builder(builder: (context) {
              final activa = f['disponible'] == 1 || f['disponible'] == true;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(activa ? Icons.event_available : Icons.event_busy,
                      color: activa ? null : Colors.grey),
                  title: Text(
                    '${f['fecha']}  ·  ${f['hora_inicio']} - ${f['hora_fin']}',
                    style: activa ? null : const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
                  ),
                  subtitle: Text(activa ? 'Activa' : 'Desactivada'),
                  trailing: activa
                      ? IconButton(
                          tooltip: context.t.agendaBienestarDesactivar,
                          icon: const Icon(Icons.visibility_off_outlined),
                          onPressed: () => _desactivarFranja(f['id']),
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }
}
