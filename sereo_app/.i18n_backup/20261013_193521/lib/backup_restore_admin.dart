import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'api_config.dart';
import 'theme.dart';

class BackupRestoreAdminScreen extends StatefulWidget {
  final int adminId;

  const BackupRestoreAdminScreen({super.key, required this.adminId});

  @override
  State<BackupRestoreAdminScreen> createState() => _BackupRestoreAdminScreenState();
}

class _BackupRestoreAdminScreenState extends State<BackupRestoreAdminScreen> {
  bool _restaurando = false;

  Future<void> _descargarBackup() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/backup_bd.php?admin_id=${widget.adminId}');
    final pudoAbrir = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!pudoAbrir && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo generar el backup.')));
    }
  }

  Future<void> _elegirYRestaurar() async {
    // API de file_picker v13: ya no existe "FilePicker.platform", y
    // para un solo archivo se usa pickFile() en vez de pickFiles().
    final archivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['sql'],
    );

    if (archivo == null) return;
    if (!mounted) return;

    final nombreArchivo = archivo.name;
    // En v13, leer el contenido del archivo es un método propio del
    // archivo (asíncrono), ya no una propiedad ".bytes" directa.
    final bytes = await archivo.readAsBytes();
    final contenidoSql = utf8.decode(bytes);

    // Doble confirmación: esta acción reemplaza TODA la base de datos,
    // así que el riesgo de un clic accidental es alto.
    final confirmarPaso1 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Restaurar base de datos'),
        content: Text(
          'Vas a restaurar desde el archivo "$nombreArchivo".\n\n'
          'Esto BORRA todos los datos actuales (usuarios, citas, SOS, '
          'autoevaluaciones, todo) y los reemplaza por los del backup. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorSos, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Entiendo, continuar'),
          ),
        ],
      ),
    );

    if (confirmarPaso1 != true || !mounted) return;

    final controladorConfirmacion = TextEditingController();
    final confirmarPaso2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmación final'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escribe RESTAURAR (en mayúsculas) para confirmar:'),
            const SizedBox(height: 10),
            TextField(controller: controladorConfirmacion, autofocus: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorSos, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, controladorConfirmacion.text.trim() == 'RESTAURAR'),
            child: const Text('Restaurar ahora'),
          ),
        ],
      ),
    );

    if (confirmarPaso2 != true) return;

    setState(() => _restaurando = true);

    try {
      final respuesta = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/restaurar_bd.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'admin_id': widget.adminId,
          'contenido_sql': contenidoSql,
        }),
      );
      final datos = jsonDecode(respuesta.body);

      if (!mounted) return;

      if (respuesta.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${datos['error']}'), backgroundColor: colorSos),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Base de datos restaurada correctamente.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
      }
    } finally {
      if (mounted) setState(() => _restaurando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.backup_outlined, color: primarioOscuro),
              title: const Text('Generar backup', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Descarga un archivo .sql con toda la información actual.'),
              trailing: const Icon(Icons.download_outlined),
              onTap: _descargarBackup,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.restore_outlined, color: colorSos),
              title: const Text('Restaurar backup', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Reemplaza TODOS los datos actuales por los de un archivo .sql.'),
              trailing: _restaurando
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload_outlined),
              onTap: _restaurando ? null : _elegirYRestaurar,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Recomendación: genera un backup regularmente (por ejemplo, antes de '
              'cada entrega), y guárdalo en un lugar seguro fuera del computador '
              '(correo, USB, nube).',
              style: TextStyle(fontSize: 12, color: textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}