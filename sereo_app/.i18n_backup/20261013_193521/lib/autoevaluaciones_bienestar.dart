import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'theme.dart';
import 'api_config.dart';

class AutoevaluacionesBienestarScreen extends StatefulWidget {
  const AutoevaluacionesBienestarScreen({super.key});

  @override
  State<AutoevaluacionesBienestarScreen> createState() => _AutoevaluacionesBienestarScreenState();
}

class _AutoevaluacionesBienestarScreenState extends State<AutoevaluacionesBienestarScreen> {
  List<dynamic> _resultados = [];
  bool _cargando = true;
  String _filtro = 'todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/autoevaluaciones_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rol': 'bienestar',
          if (_filtro != 'todos') 'clasificacion': _filtro,
        }),
      );
      final datos = jsonDecode(respuesta.body);
      if (mounted) setState(() => _resultados = datos['resultados'] ?? []);
    } catch (e) {
      // deja como estaba
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
              _chipFiltro('todos', 'Todos'),
              _chipFiltro('Severo', 'Severo'),
              _chipFiltro('Moderadamente severo', 'Mod. severo'),
              _chipFiltro('Moderado', 'Moderado'),
              _chipFiltro('Leve', 'Leve'),
              _chipFiltro('Minimo', 'Mínimo'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_cargando) const Expanded(child: Center(child: CircularProgressIndicator())),

        if (!_cargando && _resultados.isEmpty)
          const Expanded(child: Center(child: Text('No hay resultados en este filtro.'))),

        if (!_cargando && _resultados.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, i) {
                final r = _resultados[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(r['estudiante_nombre']),
                    subtitle: Text(
                      '${r['programa_academico'] ?? ''} · ${r['fecha']} · Puntaje: ${r['puntaje_total']}/27',
                    ),
                    trailing: Chip(
                      label: Text(r['clasificacion'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                      backgroundColor: _colorClasificacion(r['clasificacion']),
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
