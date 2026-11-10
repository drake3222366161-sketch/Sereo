import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'api_config.dart';
import 'package:sereo_app/l10n_ext.dart';

class CitasBienestarScreen extends StatefulWidget {
  final int profesionalId;

  const CitasBienestarScreen({super.key, required this.profesionalId});

  @override
  State<CitasBienestarScreen> createState() => _CitasBienestarScreenState();
}

class _CitasBienestarScreenState extends State<CitasBienestarScreen> {
  List<dynamic> _citas = [];
  bool _cargando = true;
  String _filtro = 'pendiente';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/citas_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rol': 'bienestar',
          'profesional_id': widget.profesionalId,
          if (_filtro != 'todas') 'estado': _filtro,
        }),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _citas = datos['citas'] ?? []);
    } catch (e) {
      // deja como estaba
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _accion(int citaId, String accion, {String? nuevaFecha, String? nuevaHora}) async {
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

  Future<void> _abrirDialogoReagendar(int citaId) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (hora == null) return;

    final fechaTexto =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final horaTexto = '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

    await _accion(citaId, 'reagendar', nuevaFecha: fechaTexto, nuevaHora: horaTexto);
  }

  Widget _chipFiltro(String valor, String etiqueta) {
    final activo = _filtro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(etiqueta),
        selected: activo,
        onSelected: (_) {
          setState(() => _filtro = valor);
          _cargar();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chipFiltro('pendiente', 'Pendientes'),
              _chipFiltro('confirmada', 'Confirmadas'),
              _chipFiltro('reagendada', 'Reagendadas'),
              _chipFiltro('atendida', 'Atendidas'),
              _chipFiltro('cancelada', 'Canceladas'),
              _chipFiltro('todas', 'Todas'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_cargando) const Expanded(child: Center(child: CircularProgressIndicator())),

        if (!_cargando && _citas.isEmpty)
          Expanded(child: Center(child: Text(context.t.citasBienestarNoHayCitasEn))),

        if (!_cargando && _citas.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _citas.length,
              itemBuilder: (context, i) {
                final c = _citas[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
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
                              label: Text(textoEstado(c['estado']),
                                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: colorEstado(c['estado']),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        if (c['programa_academico'] != null)
                          Text(c['programa_academico'],
                              style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text('Fecha: ${c['fecha_hora']}'),
                        if (c['motivo'] != null) Text('Motivo: ${c['motivo']}'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (c['estado'] == 'pendiente')
                              ElevatedButton(
                                onPressed: () => _accion(c['id'], 'confirmar'),
                                child: Text(context.t.agendaBienestarConfirmar),
                              ),
                            if (c['estado'] == 'confirmada')
                              ElevatedButton(
                                onPressed: () => _accion(c['id'], 'atendida'),
                                child: Text(context.t.agendaBienestarMarcarAtendida),
                              ),
                            if (c['estado'] == 'pendiente' || c['estado'] == 'confirmada') ...[
                              OutlinedButton(
                                onPressed: () => _abrirDialogoReagendar(c['id']),
                                child: Text(context.t.agendaBienestarReagendar),
                              ),
                              OutlinedButton(
                                onPressed: () => _accion(c['id'], 'cancelar'),
                                child: Text(context.t.agendaBienestarCancelar),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
