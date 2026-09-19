import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';

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
        Uri.parse('http://localhost/sereo/backend/public/sos_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rol': 'estudiante', 'estudiante_id': widget.estudianteId}),
      );
      final datos = jsonDecode(respuesta.body);
      setState(() => _misSolicitudes = datos['solicitudes'] ?? []);
    } catch (e) {
      setState(() => _error = 'No se pudo cargar tu historial.');
    } finally {
      setState(() => _cargandoLista = false);
    }
  }

  Future<void> _enviarSolicitud() async {
    if (_notaController.text.trim().isEmpty) {
      setState(() => _error = 'Cuéntanos brevemente qué necesitas.');
      return;
    }

    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/sos_crear.php'),
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
          const SnackBar(content: Text('Solicitud enviada. Bienestar la atenderá pronto.')),
        );
      }
      await _cargarSolicitudes();
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      setState(() => _enviando = false);
    }
  }

  Future<void> _cancelarSolicitud(int solicitudId) async {
    try {
      final respuesta = await http.post(
        Uri.parse('http://localhost/sereo/backend/public/sos_actualizar_estado.php'),
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

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return const Color(0xFFB98900);
      case 'en_proceso':
        return primarioOscuro;
      case 'atendida':
        return const Color(0xFF2E7D32);
      case 'cancelada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _textoEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En proceso';
      case 'atendida':
        return 'Atendida';
      case 'cancelada':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitud prioritaria (SOS)')),
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
              child: const Text(
                'Si estás en una situación de crisis o riesgo inmediato, '
                'comunícate directamente con la línea de emergencias. '
                'Este formulario notifica a Bienestar, pero puede tardar '
                'unos minutos en ser leído.',
                style: TextStyle(fontSize: 13, color: Color(0xFF791F1F)),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Nueva solicitud', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
              decoration: const InputDecoration(
                labelText: '¿Qué necesitas? (breve)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono de contacto (opcional)',
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
                  : const Text('Enviar solicitud'),
            ),

            const SizedBox(height: 32),
            const Text('Mis solicitudes anteriores',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),

            if (_cargandoLista) const Center(child: CircularProgressIndicator()),

            if (!_cargandoLista && _misSolicitudes.isEmpty)
              const Text('Aún no has enviado ninguna solicitud.',
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
                              label: Text(_textoEstado(s['estado']),
                                  style: const TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: _colorEstado(s['estado']),
                              padding: EdgeInsets.zero,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Cancelar',
                              onPressed: () => _cancelarSolicitud(s['id']),
                            ),
                          ],
                        )
                      : Chip(
                          label: Text(_textoEstado(s['estado']),
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                          backgroundColor: _colorEstado(s['estado']),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
