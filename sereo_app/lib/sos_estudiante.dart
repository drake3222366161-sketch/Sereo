import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'api_config.dart';
import 'package:sereo_app/l10n_ext.dart';
import 'nivel_texto.dart';

class SosEstudianteScreen extends StatefulWidget {
  final int estudianteId;
  final String nombreEstudiante;

  const SosEstudianteScreen({
    super.key,
    required this.estudianteId,
    required this.nombreEstudiante,
  });

  @override
  State<SosEstudianteScreen> createState() => _SosEstudianteScreenState();
}

class _SosEstudianteScreenState extends State<SosEstudianteScreen> {
  final _notaController = TextEditingController();
  final _telefonoController = TextEditingController();

  List<dynamic> _misSolicitudes = [];
  bool _cargandoLista = true;
  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudes();
  }

  Future<void> _cargarSolicitudes() async {
    setState(() => _cargandoLista = true);
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sos_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rol': 'estudiante', 'estudiante_id': widget.estudianteId}),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _misSolicitudes = datos['solicitudes'] ?? []);
    } catch (e) {
      setState(() => _error = context.t.sosEstudianteNoSePudoCargar);
    } finally {
      setState(() => _cargandoLista = false);
    }
  }

  Future<void> _enviarSolicitud() async {
    if (_notaController.text.trim().isEmpty) {
      setState(() => _error = context.t.sosEstudianteCuentanosBrevemente);
      return;
    }

    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sos_crear.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estudiante_id': widget.estudianteId,
          'nota': _notaController.text.trim(),
          'telefono_contacto': _telefonoController.text.trim(),
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        setState(() => _error = datos['error']);
        return;
      }

      _notaController.clear();
      _telefonoController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.sosEstudianteSolicitudEnviadaBienestarLa)),
        );
      }
      await _cargarSolicitudes();
    } catch (e) {
      setState(() => _error = context.t.err_connection(e.toString()));
    } finally {
      setState(() => _enviando = false);
    }
  }

  Future<void> _cancelarSolicitud(int solicitudId) async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/sos_actualizar_estado.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'solicitud_id': solicitudId,
          'nuevo_estado': 'cancelada',
          'usuario_id': widget.estudianteId,
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (respuesta.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(datos['error'])));
        }
        return;
      }
      await _cargarSolicitudes();
    } catch (e) {
      // silencioso: si falla, la lista simplemente no se actualiza
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.homeEstudianteSolicitudPrioritariaSos)),
      body: RefreshIndicator(
        onRefresh: _cargarSolicitudes,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                context.t.sosEstudianteSiEstasEnUna,
                style: TextStyle(fontSize: 13, color: Color(0xFF791F1F)),
              ),
            ),
            const SizedBox(height: 20),

            Text(context.t.sosEstudianteNuevaSolicitud, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!, style: const TextStyle(color: Color(0xFF791F1F), fontSize: 13)),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _notaController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.t.sosEstudianteQueNecesitasBreve,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.t.sosEstudianteTelefonoDeContactoOpcional,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primario,
                foregroundColor: primarioMuyOscuro,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _enviando ? null : _enviarSolicitud,
              child: _enviando
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(context.t.sosEstudianteEnviarSolicitud),
            ),

            const SizedBox(height: 32),
            Text(context.t.sosEstudianteMisSolicitudesAnteriores,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),

            if (_cargandoLista) const Center(child: CircularProgressIndicator()),

            if (!_cargandoLista && _misSolicitudes.isEmpty)
              Text(context.t.sosEstudianteAunNoHasEnviado,
                  style: TextStyle(color: textoSecundario)),

            for (final s in _misSolicitudes)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(s['nota'], maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(s['fecha_solicitud']),
                  trailing: s['estado'] == 'pendiente'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(textoEstadoL10n(context, s['estado']),
                                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: colorEstado(s['estado']),
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: context.t.agendaBienestarCancelar,
                              onPressed: () => _cancelarSolicitud(s['id']),
                            ),
                          ],
                        )
                      : Chip(
                          label: Text(textoEstadoL10n(context, s['estado']),
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: colorEstado(s['estado']),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
