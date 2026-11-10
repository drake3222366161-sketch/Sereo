import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'api_config.dart';
import 'package:sereo_app/l10n_ext.dart';
import 'nivel_texto.dart';

class SosBienestarScreen extends StatefulWidget {
  final int usuarioId; // id del profesional de bienestar logueado

  const SosBienestarScreen({super.key, required this.usuarioId});

  @override
  State<SosBienestarScreen> createState() => _SosBienestarScreenState();
}

class _SosBienestarScreenState extends State<SosBienestarScreen> {
  List<dynamic> _solicitudes = [];
  bool _cargando = true;
  String _filtro = 'pendiente'; // pestaña activa

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sos_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rol': 'bienestar',
          if (_filtro != 'todas') 'estado': _filtro,
        }),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _solicitudes = datos['solicitudes'] ?? []);
    } catch (e) {
      // si falla, dejamos la lista como estaba
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarEstado(int solicitudId, String nuevoEstado) async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sos_actualizar_estado.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'nuevo_estado': nuevoEstado,
          'usuario_id': widget.usuarioId,
        }),
      );
      if (respuesta.statusCode == 200) {
        await _cargar();
      }
    } catch (e) {
      // silencioso
    }
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
              _chipFiltro('pendiente', context.t.filtroPendientes),
              _chipFiltro('en_proceso', context.t.filtroEnProceso),
              _chipFiltro('atendida', context.t.filtroAtendidas),
              _chipFiltro('cancelada', context.t.filtroCanceladas),
              _chipFiltro('todas', context.t.filtroTodas),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_cargando) const Expanded(child: Center(child: CircularProgressIndicator())),

        if (!_cargando && _solicitudes.isEmpty)
          Expanded(child: Center(child: Text(context.t.sosBienestarNoHaySolicitudesEn))),

        if (!_cargando && _solicitudes.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _solicitudes.length,
              itemBuilder: (context, i) {
                final s = _solicitudes[i];
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
                              child: Text(s['estudiante_nombre'],
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Chip(
                              label: Text(textoEstadoL10n(context, s['estado']),
                                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: colorEstado(s['estado']),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Text(s['fecha_solicitud'],
                                style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                        if (s['programa_academico'] != null)
                          Text(s['programa_academico'],
                              style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text(s['nota']),
                        if (s['telefono_contacto'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(context.t.sosTelefono(s['telefono_contacto']),
                                style: const TextStyle(fontSize: 12)),
                          ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (s['estado'] == 'pendiente')
                              ElevatedButton(
                                onPressed: () => _cambiarEstado(s['id'], 'en_proceso'),
                                child: Text(context.t.sosBienestarTomarCaso),
                              ),
                            if (s['estado'] == 'en_proceso')
                              ElevatedButton(
                                onPressed: () => _cambiarEstado(s['id'], 'atendida'),
                                child: Text(context.t.agendaBienestarMarcarAtendida),
                              ),
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
