import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'theme.dart';

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
        appBar: AppBar(title: const Text('Política de tratamiento de datos')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('POLÍTICA DE TRATAMIENTO DE DATOS PERSONALES — SEREO',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _seccion('1. Responsable del tratamiento',
                          'SEREO es una plataforma desarrollada para el área de Bienestar '
                          'Universitario de la Universidad de Cundinamarca, orientada al '
                          'acompañamiento psicológico y emocional de su comunidad estudiantil. '
                          'El área de Bienestar Universitario actúa como responsable del '
                          'tratamiento de los datos personales recolectados a través de esta '
                          'aplicación.'),
                      _seccion('2. Datos que se recolectan',
                          '• Datos de identificación: nombre completo, correo institucional, '
                          'programa académico.\n'
                          '• Credenciales de acceso: contraseña (almacenada de forma cifrada).\n'
                          '• Datos sensibles de salud mental: solicitudes de atención prioritaria '
                          '(SOS), diario emocional, autoevaluaciones psicológicas, e historial de '
                          'citas con profesionales de Bienestar.\n'
                          '• Datos técnicos: preferencias de la aplicación y datos de sesión.'),
                      _seccion('3. Finalidad del tratamiento',
                          'Verificar tu identidad y pertenencia a la comunidad universitaria, '
                          'gestionar solicitudes de atención psicológica y citas, permitir el '
                          'seguimiento de tu bienestar emocional por parte de profesionales '
                          'autorizados, y generar estadísticas agregadas y anónimas para apoyar '
                          'decisiones institucionales.'),
                      _seccion('4. Confidencialidad de la información sensible',
                          'La información relacionada con tu estado emocional (diario, '
                          'autoevaluaciones, solicitudes SOS) es confidencial. Solo el personal '
                          'de Bienestar autorizado tiene acceso, y únicamente en el contexto '
                          'necesario para brindarte atención. El personal administrativo del '
                          'sistema NO tiene acceso a esta información bajo ninguna circunstancia.'),
                      _seccion('5. Conservación de la información',
                          'La información no se elimina de forma permanente. Las solicitudes, '
                          'citas y cuentas pueden cancelarse o desactivarse, pero se conservan '
                          'con fines de trazabilidad, auditoría y continuidad del '
                          'acompañamiento.'),
                      _seccion('6. Tus derechos',
                          'Tienes derecho a conocer, actualizar y rectificar tus datos; ser '
                          'informado sobre su uso; presentar quejas ante las autoridades '
                          'competentes; y revocar tu autorización o solicitar la supresión de '
                          'tus datos, cuando no exista un deber legal que lo impida.'),
                      _seccion('7. Uso de almacenamiento local',
                          'SEREO utiliza almacenamiento local en tu dispositivo (similar a las '
                          'cookies en aplicaciones web) para mantener tu sesión activa y '
                          'recordar tus preferencias, como el tema visual. Esta información '
                          'permanece únicamente en tu dispositivo.'),
                      _seccion('8. Aceptación',
                          'El uso de SEREO requiere la aceptación expresa de esta política, de '
                          'acuerdo con la Ley 1581 de 2012 y sus decretos reglamentarios.'),
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
                        title: const Text(
                          'He leído y acepto la política de tratamiento de datos personales.',
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
                            : const Text('Aceptar y continuar'),
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
