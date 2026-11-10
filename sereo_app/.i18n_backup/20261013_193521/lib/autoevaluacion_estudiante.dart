import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'api_config.dart';

class AutoevaluacionEstudianteScreen extends StatefulWidget {
  final int estudianteId;

  const AutoevaluacionEstudianteScreen({super.key, required this.estudianteId});

  @override
  State<AutoevaluacionEstudianteScreen> createState() => _AutoevaluacionEstudianteScreenState();
}

class _AutoevaluacionEstudianteScreenState extends State<AutoevaluacionEstudianteScreen> {
  List<dynamic> _preguntas = [];
  List<dynamic> _historial = [];
  final Map<int, int> _respuestas = {}; // pregunta_id -> valor (0-3)
  bool _cargando = true;
  bool _enviando = false;
  bool _mostrarFormulario = false;

  static const _opciones = [
    {'valor': 0, 'texto': 'Nunca'},
    {'valor': 1, 'texto': 'Varios días'},
    {'valor': 2, 'texto': 'Más de la mitad de los días'},
    {'valor': 3, 'texto': 'Casi todos los días'},
  ];

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() => _cargando = true);
    await Future.wait([_cargarPreguntas(), _cargarHistorial()]);
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _cargarPreguntas() async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/preguntas_listar.php'),
        headers: {'Content-Type': 'application/json'},
      );
      final datos = jsonDecode(respuesta.body);
      if (mounted) setState(() => _preguntas = datos['preguntas'] ?? []);
    } catch (e) {
      // deja como estaba
    }
  }

  Future<void> _cargarHistorial() async {
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/autoevaluaciones_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rol': 'estudiante', 'estudiante_id': widget.estudianteId}),
      );
      final datos = jsonDecode(respuesta.body);
      if (mounted) setState(() => _historial = datos['resultados'] ?? []);
    } catch (e) {
      // deja como estaba
    }
  }

  Future<void> _enviarTest() async {
    if (_respuestas.length < _preguntas.length) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Responde todas las preguntas antes de continuar.')));
      return;
    }

    setState(() => _enviando = true);

    final listaRespuestas = _respuestas.entries
        .map((e) => {'pregunta_id': e.key, 'valor': e.value})
        .toList();

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/autoevaluacion_guardar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'estudiante_id': widget.estudianteId,
          'respuestas': listaRespuestas,
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(datos['error'])));
        return;
      }

      setState(() {
        _respuestas.clear();
        _mostrarFormulario = false;
      });
      await _cargarHistorial();

      _mostrarResultado(
        puntaje: datos['puntaje_total'],
        clasificacion: datos['clasificacion'],
        alertaRiesgo: datos['alerta_riesgo'] == true,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarResultado({
    required int puntaje,
    required String clasificacion,
    required bool alertaRiesgo,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !alertaRiesgo,
      builder: (_) => AlertDialog(
        title: const Text('Resultado de tu autoevaluación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Puntaje: $puntaje / 27'),
            const SizedBox(height: 4),
            Text('Nivel: $clasificacion', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (alertaRiesgo) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorSos.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorSos),
                ),
                child: const Text(
                  'Una de tus respuestas indica que podrías estar pasando por un '
                  'momento difícil. No estás solo(a) - te recomendamos hablar con '
                  'Bienestar Universitario lo antes posible, o usar el botón de '
                  'Solicitud prioritaria (SOS) desde la pantalla principal.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Text(
                'Este resultado es un tamizaje, no un diagnóstico. Si sientes que '
                'necesitas apoyo, Bienestar Universitario está disponible para ti.',
                style: TextStyle(fontSize: 13, color: textoSecundario),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Color _colorClasificacion(String c) {
    switch (c) {
      case 'Minimo':
        return const Color(0xFF3FA34D);
      case 'Leve':
        return primarioOscuro;
      case 'Moderado':
        return const Color(0xFFD98324);
      case 'Moderadamente severo':
        return const Color(0xFFC1540C);
      case 'Severo':
        return colorSos;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autoevaluación')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _mostrarFormulario
              ? _construirFormulario()
              : _construirInicio(),
    );
  }

  Widget _construirInicio() {
    return RefreshIndicator(
      onRefresh: _cargarTodo,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PHQ-9', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 6),
                const Text(
                  'Test breve de tamizaje, usado ampliamente en entornos clínicos '
                  'para identificar señales de ánimo bajo en las últimas 2 semanas. '
                  'Toma menos de 3 minutos.',
                  style: TextStyle(fontSize: 13, color: textoSecundario),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primario,
                    foregroundColor: primarioMuyOscuro,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => setState(() => _mostrarFormulario = true),
                  child: const Text('Comenzar autoevaluación'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text('Mi historial', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),

          if (_historial.isEmpty)
            const Text('Aún no has realizado ninguna autoevaluación.',
                style: TextStyle(color: textoSecundario, fontSize: 13)),

          for (final h in _historial)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(h['fecha']),
                subtitle: Text('Puntaje: ${h['puntaje_total']} / 27'),
                trailing: Chip(
                  label: Text(h['clasificacion'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                  backgroundColor: _colorClasificacion(h['clasificacion']),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Durante las últimas 2 semanas, ¿con qué frecuencia te ha molestado '
            'cada uno de los siguientes problemas?',
            style: TextStyle(fontSize: 13, color: textoSecundario),
          ),
          const SizedBox(height: 16),

          for (final p in _preguntas)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p['orden']}. ${p['texto_pregunta']}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    for (final o in _opciones)
                      RadioListTile<int>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(o['texto'] as String, style: const TextStyle(fontSize: 13)),
                        value: o['valor'] as int,
                        groupValue: _respuestas[p['id']],
                        onChanged: (valor) => setState(() => _respuestas[p['id']] = valor!),
                      ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primario,
              foregroundColor: primarioMuyOscuro,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _enviando ? null : _enviarTest,
            child: _enviando
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enviar respuestas'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _enviando ? null : () => setState(() => _mostrarFormulario = false),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
