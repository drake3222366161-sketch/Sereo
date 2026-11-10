import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';
import 'theme.dart';

class ReportesBienestarScreen extends StatelessWidget {
  const ReportesBienestarScreen({super.key});

  Future<void> _abrir(BuildContext context, String rutaArchivo) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$rutaArchivo');
    final pudoAbrir = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!pudoAbrir && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el reporte. Verifica tu conexión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exportar a Excel (CSV)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          const Text(
            'Se descarga un archivo que abre directamente en Excel, listo para '
            'filtrar y analizar.',
            style: TextStyle(fontSize: 12, color: textoSecundario),
          ),
          const SizedBox(height: 14),

          _TarjetaReporte(
            icono: Icons.table_chart_outlined,
            titulo: 'Estadísticas por programa académico',
            descripcion: 'SOS, citas y autoevaluaciones agrupadas por carrera — el reporte más útil '
                'para identificar dónde hay mayor necesidad de acompañamiento.',
            onTap: () => _abrir(context, 'reporte_estadisticas_csv.php'),
          ),
          const SizedBox(height: 10),
          _TarjetaReporte(
            icono: Icons.error_outline,
            titulo: 'Historial de solicitudes SOS',
            descripcion: 'Listado completo con estudiante, estado y fechas.',
            onTap: () => _abrir(context, 'reporte_sos_csv.php'),
          ),
          const SizedBox(height: 10),
          _TarjetaReporte(
            icono: Icons.calendar_month_outlined,
            titulo: 'Historial de citas',
            descripcion: 'Todas las citas agendadas, con su estado y profesional asignado.',
            onTap: () => _abrir(context, 'reporte_citas_csv.php'),
          ),

          const SizedBox(height: 28),
          const Text('Resumen ejecutivo (PDF)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          const Text(
            'Se abre una página lista para imprimir o guardar como PDF (Ctrl+P), '
            'ideal para presentar en una reunión.',
            style: TextStyle(fontSize: 12, color: textoSecundario),
          ),
          const SizedBox(height: 14),

          _TarjetaReporte(
            icono: Icons.picture_as_pdf_outlined,
            titulo: 'Resumen ejecutivo de indicadores',
            descripcion: 'Un vistazo general: totales, SOS pendientes, y promedio del PHQ-9 por programa.',
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
