import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'api_config.dart';
import 'theme.dart';
import 'package:sereo_app/l10n_ext.dart';

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
          .showSnackBar(SnackBar(content: Text(context.t.backupRestoreAdminNoSePudoGenerar)));
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
        title: Text(context.t.backupRestoreAdminRestaurarBaseDeDatos),
        content: Text(
          context.t.backupRestoreAdminVasARestaurarDesde(nombreArchivo),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t.agendaBienestarCancelar)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorSos, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.t.backupRestoreAdminEntiendoContinuar),
          ),
        ],
      ),
    );

    if (confirmarPaso1 != true || !mounted) return;

    final controladorConfirmacion = TextEditingController();
    final confirmarPaso2 = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.t.backupRestoreAdminConfirmacionFinal),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t.backupRestoreAdminEscribeRestaurarEnMayusculas),
            const SizedBox(height: 10),
            TextField(controller: controladorConfirmacion, autofocus: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.t.agendaBienestarCancelar)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorSos, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, controladorConfirmacion.text.trim() == 'RESTAURAR'),
            child: Text(context.t.backupRestoreAdminRestaurarAhora),
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
        SnackBar(content: Text(context.t.backupRestoreAdminBaseDeDatosRestaurada)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.autoevaluacionEstudianteErrorDeConexion(e))));
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
              title: Text(context.t.backupRestoreAdminGenerarBackup, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(context.t.backupRestoreAdminDescargaUnArchivoSql),
              trailing: const Icon(Icons.download_outlined),
              onTap: _descargarBackup,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.restore_outlined, color: colorSos),
              title: Text(context.t.backupRestoreAdminRestaurarBackup, style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(context.t.backupRestoreAdminReemplazaTodosLosDatos),
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
            child: Text(
              context.t.backupRestoreAdminRecomendacionGeneraUnBackup,
              style: TextStyle(fontSize: 12, color: textoSecundario),
            ),
          ),
        ],
      ),
    );
  }
}