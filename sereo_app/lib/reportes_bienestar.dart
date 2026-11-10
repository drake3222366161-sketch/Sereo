import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';
import 'theme.dart';
import 'package:sereo_app/l10n_ext.dart';

class ReportesBienestarScreen extends StatelessWidget {
  final int usuarioId;

  const ReportesBienestarScreen({super.key, required this.usuarioId});

  Future<void> _abrir(BuildContext context, String rutaArchivo) async {
    // usuario_id va en la URL para que quede en el log quién exportó el reporte
    final url = Uri.parse('${ApiConfig.baseUrl}/$rutaArchivo?usuario_id=$usuarioId');
    final pudoAbrir = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!pudoAbrir && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.reportesBienestarNoSePudoAbrir)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.reportesBienestarExportarAExcelCsv,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            context.t.reportesBienestarSeDescargaUnArchivo,
            style: TextStyle(fontSize: 12, color: textoSecundario),
          ),
          const SizedBox(height: 14),

          _TarjetaReporte(
            icono: Icons.table_chart_outlined,
            titulo: context.t.reportesBienestarEstadisticasPorProgramaAcademico,
            descripcion: context.t.reportesBienestarSosCitasYAutoevaluaciones,
            onTap: () => _abrir(context, 'reporte_estadisticas_csv.php'),
          ),
          const SizedBox(height: 10),
          _TarjetaReporte(
            icono: Icons.error_outline,
            titulo: context.t.reportesBienestarHistorialDeSolicitudesSos,
            descripcion: context.t.reportesBienestarListadoCompletoConEstudiante,
            onTap: () => _abrir(context, 'reporte_sos_csv.php'),
          ),
          const SizedBox(height: 10),
          _TarjetaReporte(
            icono: Icons.calendar_month_outlined,
            titulo: context.t.reportesBienestarHistorialDeCitas,
            descripcion: context.t.reportesBienestarTodasLasCitasAgendadas,
            onTap: () => _abrir(context, 'reporte_citas_csv.php'),
          ),

          const SizedBox(height: 28),
          Text(context.t.reportesBienestarResumenEjecutivoPdf,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            context.t.reportesBienestarSeAbreUnaPagina,
            style: TextStyle(fontSize: 12, color: textoSecundario),
          ),
          const SizedBox(height: 14),

          _TarjetaReporte(
            icono: Icons.picture_as_pdf_outlined,
            titulo: context.t.reportesBienestarResumenEjecutivoDeIndicadores,
            descripcion: context.t.reportesBienestarUnVistazoGeneralTotales,
            onTap: () => _abrir(context, 'reporte_resumen_html.php'),
          ),
        ],
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _TarjetaReporte({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icono, color: primarioOscuro),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(descripcion, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.download_outlined),
        onTap: onTap,
        isThreeLine: true,
      ),
    );
  }
}
