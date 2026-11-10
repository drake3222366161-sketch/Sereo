import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'theme.dart';
import 'package:sereo_app/l10n_ext.dart';

class PoliticaScreen extends StatefulWidget {
  final int usuarioId;
  final void Function(BuildContext context) alContinuar;

  const PoliticaScreen({
    super.key,
    required this.usuarioId,
    required this.alContinuar,
  });

  @override
  State<PoliticaScreen> createState() => _PoliticaScreenState();
}

class _PoliticaScreenState extends State<PoliticaScreen> {
  bool _aceptado = false;
  bool _enviando = false;

  Future<void> _confirmar() async {
    setState(() => _enviando = true);
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/aceptar_politica.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': widget.usuarioId}),
      );
    } catch (e) {
      // aunque falle el guardado remoto, dejamos avanzar - no queremos
      // trabar a la persona por un problema de red en este paso
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
        widget.alContinuar(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // no se puede "regresar" sin aceptar
      child: Scaffold(
        appBar: AppBar(title: Text(context.t.politicaPoliticaDeTratamientoDe)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.t.politicaPoliticaDeTratamientoDe2,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _seccion(context.t.politicaSeccion1Titulo, context.t.politicaSeccion1Texto),
                      _seccion(context.t.politicaSeccion2Titulo, context.t.politicaSeccion2Texto),
                      _seccion(context.t.politicaSeccion3Titulo, context.t.politicaSeccion3Texto),
                      _seccion(context.t.politicaSeccion4Titulo, context.t.politicaSeccion4Texto),
                      _seccion(context.t.politicaSeccion5Titulo, context.t.politicaSeccion5Texto),
                      _seccion(context.t.politicaSeccion6Titulo, context.t.politicaSeccion6Texto),
                      _seccion(context.t.politicaSeccion7Titulo, context.t.politicaSeccion7Texto),
                      _seccion(context.t.politicaSeccion8Titulo, context.t.politicaSeccion8Texto),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CheckboxListTile(
                        value: _aceptado,
                        onChanged: (valor) => setState(() => _aceptado = valor ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          context.t.politicaHeLeidoYAcepto,
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primario,
                          foregroundColor: primarioMuyOscuro,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: (_aceptado && !_enviando) ? _confirmar : null,
                        child: _enviando
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(context.t.politicaAceptarYContinuar),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(contenido, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
