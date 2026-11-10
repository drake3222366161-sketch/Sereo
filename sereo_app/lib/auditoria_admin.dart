import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

/// Título del módulo para el menú del Admin (se adapta al idioma activo).
String tituloAuditoria(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en' ? 'Audit log' : 'Auditoría';

// ---------------------------------------------------------------------------
// Traducciones. La base de datos guarda CÓDIGOS (LOGIN_EXITOSO, contrasena_incorrecta...)
// y aquí se convierten a texto legible en el idioma activo. Así, si cambias el
// idioma de la app, todo el historial (también los registros viejos) cambia.
// Formato de cada entrada: [español, inglés]
// ---------------------------------------------------------------------------
const Map<String, List<String>> _mapaAcciones = {
  'LOGIN_EXITOSO': ['Inició sesión', 'Logged in'],
  'LOGIN_FALLIDO': ['Intento de inicio de sesión fallido', 'Failed login attempt'],
  'LOGOUT': ['Cerró sesión', 'Logged out'],
  'SESION_ANTERIOR_REEMPLAZADA': ['Sesión anterior reemplazada por un nuevo inicio de sesión', 'Previous session replaced by a new login'],
  'SESION_INVALIDADA': ['Sesión cerrada por inicio de sesión en otro dispositivo', 'Session closed by a login on another device'],
  'SESION_CERRADA_POR_INACTIVIDAD': ['Sesión cerrada por inactividad', 'Session closed due to inactivity'],
  'BLOQUEO_PANTALLA_INACTIVIDAD': ['Pantalla bloqueada por inactividad', 'Screen locked due to inactivity'],
  'DESBLOQUEO_PANTALLA': ['Pantalla desbloqueada', 'Screen unlocked'],
  'DESBLOQUEO_FALLIDO': ['Intento fallido de desbloquear la pantalla', 'Failed attempt to unlock the screen'],
  'REGISTRO_EXITOSO': ['Creó su cuenta', 'Signed up'],
  'REGISTRO_FALLIDO': ['Registro fallido', 'Failed sign-up'],
  'POLITICA_ACEPTADA': ['Aceptó la política de datos', 'Accepted the data policy'],
  'USUARIO_CREADO': ['Creó una cuenta', 'Created an account'],
  'USUARIO_ACTUALIZADO': ['Editó una cuenta', 'Edited an account'],
  'USUARIO_ACTIVADO': ['Activó una cuenta', 'Activated an account'],
  'USUARIO_DESACTIVADO': ['Desactivó una cuenta', 'Deactivated an account'],
  'USUARIO_CREACION_DENEGADA': ['Intento denegado de crear una cuenta', 'Denied attempt to create an account'],
  'USUARIO_DESACTIVACION_DENEGADA': ['Intento denegado de desactivar su propia cuenta', 'Denied attempt to deactivate own account'],
  'CITA_CREADA': ['Solicitó una cita', 'Requested an appointment'],
  'CITA_CONFIRMADA': ['Confirmó una cita', 'Confirmed an appointment'],
  'CITA_ATENDIDA': ['Marcó una cita como atendida', 'Marked an appointment as attended'],
  'CITA_CANCELADA': ['Canceló una cita', 'Cancelled an appointment'],
  'CITA_REAGENDADA': ['Reagendó una cita', 'Rescheduled an appointment'],
  'CITA_ACCION_DENEGADA': ['Acción denegada sobre una cita', 'Denied action on an appointment'],
  'DISPONIBILIDAD_CREADA': ['Agregó disponibilidad', 'Added availability'],
  'DISPONIBILIDAD_DESACTIVADA': ['Desactivó una franja de disponibilidad', 'Deactivated an availability slot'],
  'DISPONIBILIDAD_ACCION_DENEGADA': ['Acción denegada sobre la disponibilidad', 'Denied action on availability'],
  'SOS_CREADO': ['Envió una solicitud SOS', 'Sent an SOS request'],
  'SOS_ESTADO_CAMBIADO': ['Cambió el estado de una solicitud SOS', 'Changed the status of an SOS request'],
  'SOS_ACCION_DENEGADA': ['Acción denegada sobre una solicitud SOS', 'Denied action on an SOS request'],
  'AUTOEVALUACION_COMPLETADA': ['Completó una autoevaluación', 'Completed a self-assessment'],
  'REPORTE_CITAS_EXPORTADO': ['Exportó el reporte de citas', 'Exported the appointments report'],
  'REPORTE_SOS_EXPORTADO': ['Exportó el reporte de solicitudes SOS', 'Exported the SOS requests report'],
  'REPORTE_USUARIOS_EXPORTADO': ['Exportó el reporte de usuarios', 'Exported the users report'],
  'REPORTE_ESTADISTICAS_EXPORTADO': ['Exportó las estadísticas por programa', 'Exported the statistics by program'],
  'REPORTE_RESUMEN_PDF_GENERADO': ['Generó el resumen ejecutivo (PDF)', 'Generated the executive summary (PDF)'],
  'BACKUP_GENERADO': ['Generó una copia de seguridad', 'Generated a backup'],
  'BACKUP_DENEGADO': ['Intento denegado de generar una copia de seguridad', 'Denied attempt to generate a backup'],
  'RESTAURACION_EJECUTADA': ['Restauró la base de datos', 'Restored the database'],
  'RESTAURACION_FALLIDA': ['Falló la restauración de la base de datos', 'Database restore failed'],
  'RESTAURACION_DENEGADA': ['Intento denegado de restaurar la base de datos', 'Denied attempt to restore the database'],
  'LOGS_CONSULTADOS': ['Consultó el registro de auditoría', 'Viewed the audit log'],
  'ACCESO_LOGS_DENEGADO': ['Intento denegado de ver el registro de auditoría', 'Denied attempt to view the audit log'],
};

const Map<String, List<String>> _mapaModulos = {
  'auth': ['Acceso y sesión', 'Access & session'],
  'politica': ['Política de datos', 'Data policy'],
  'usuarios': ['Usuarios', 'Users'],
  'citas': ['Citas', 'Appointments'],
  'disponibilidad': ['Disponibilidad', 'Availability'],
  'sos': ['SOS', 'SOS'],
  'autoevaluacion': ['Autoevaluación', 'Self-assessment'],
  'reportes': ['Reportes', 'Reports'],
  'backup': ['Copias de seguridad', 'Backups'],
  'auditoria': ['Auditoría', 'Audit'],
};

const Map<String, List<String>> _mapaResultados = {
  'ok': ['Exitoso', 'Success'],
  'error': ['Fallido', 'Failed'],
  'denegado': ['Denegado', 'Denied'],
};

const Map<String, List<String>> _mapaEtiquetas = {
  'motivo': ['Motivo', 'Reason'],
  'cita_id': ['Cita', 'Appointment'],
  'profesional_id': ['Profesional', 'Professional'],
  'fecha': ['Fecha', 'Date'],
  'hora': ['Hora', 'Time'],
  'estado_anterior': ['Estado anterior', 'Previous status'],
  'estado_nuevo': ['Estado nuevo', 'New status'],
  'solicitud_id': ['Solicitud SOS', 'SOS request'],
  'usuario_creado_id': ['Cuenta creada', 'Account created'],
  'usuario_afectado_id': ['Cuenta afectada', 'Affected account'],
  'usuario_id': ['Cuenta', 'Account'],
  'correo': ['Correo', 'Email'],
  'rol': ['Rol', 'Role'],
  'rol_solicitado': ['Rol solicitado', 'Requested role'],
  'accion': ['Acción', 'Action'],
  'intento': ['Intento', 'Attempt'],
  'id': ['Registro', 'Record'],
  'franja_id': ['Franja', 'Slot'],
  'hora_inicio': ['Hora de inicio', 'Start time'],
  'hora_fin': ['Hora de fin', 'End time'],
  'autoevaluacion_id': ['Autoevaluación', 'Self-assessment'],
  'formato': ['Formato', 'Format'],
  'tablas': ['Tablas incluidas', 'Tables included'],
  'bytes': ['Tamaño', 'Size'],
  'error': ['Error', 'Error'],
  'fecha_hora_anterior': ['Fecha y hora anterior', 'Previous date and time'],
  'nueva_fecha': ['Nueva fecha', 'New date'],
  'nueva_hora': ['Nueva hora', 'New time'],
  'nombre_completo': ['Nombre', 'Name'],
  'truncado': ['Detalle', 'Details'],
};

const Map<String, List<String>> _mapaValores = {
  'correo_no_institucional': ['Correo no institucional', 'Non-institutional email'],
  'correo_no_registrado': ['Correo no registrado', 'Email not registered'],
  'contrasena_incorrecta': ['Contraseña incorrecta', 'Wrong password'],
  'cuenta_desactivada': ['Cuenta desactivada', 'Account deactivated'],
  'nuevo_inicio_de_sesion': ['Nuevo inicio de sesión', 'New login'],
  'inicio_de_sesion_en_otro_dispositivo': ['Inicio de sesión en otro dispositivo', 'Login on another device'],
  'correo_ya_registrado': ['Correo ya registrado', 'Email already registered'],
  'autodesactivacion': ['Intentó desactivar su propia cuenta', 'Tried to deactivate their own account'],
  'cancelar_ajena': ['Intentó cancelar una solicitud ajena', "Tried to cancel someone else's request"],
  'pendiente': ['Pendiente', 'Pending'],
  'confirmada': ['Confirmada', 'Confirmed'],
  'cancelada': ['Cancelada', 'Cancelled'],
  'reagendada': ['Reagendada', 'Rescheduled'],
  'atendida': ['Atendida', 'Attended'],
  'en_proceso': ['En proceso', 'In progress'],
  'cancelar': ['Cancelar', 'Cancel'],
  'confirmar': ['Confirmar', 'Confirm'],
  'reagendar': ['Reagendar', 'Reschedule'],
  'estudiante': ['Estudiante', 'Student'],
  'bienestar': ['Bienestar', 'Wellbeing staff'],
  'admin': ['Administrador', 'Administrator'],
  'xls': ['Excel', 'Excel'],
  'pdf': ['PDF', 'PDF'],
};

const List<String> _mesesEs = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const List<String> _mesesEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// Convierte un código desconocido en algo legible: SOME_CODE -> "Some code".
String _embellecer(String c) {
  final t = c.replaceAll('_', ' ').toLowerCase();
  if (t.isEmpty) return c;
  return t[0].toUpperCase() + t.substring(1);
}

String _traducir(Map<String, List<String>> mapa, String clave, bool en) {
  final par = mapa[clave];
  if (par != null) return par[en ? 1 : 0];
  return _embellecer(clave);
}

String _traducirValor(String v, bool en) {
  final par = _mapaValores[v];
  return par != null ? par[en ? 1 : 0] : v;
}

String _formatearValor(String clave, dynamic v, bool en) {
  if (v == null) return '-';
  if ((clave == 'id' || clave.endsWith('_id')) && v is num) return '#$v';
  if (clave == 'bytes' && v is num) return '${(v / 1024).toStringAsFixed(1)} KB';
  if (v is String) return _traducirValor(v, en);
  return '$v';
}

/// Convierte el JSON de "detalle" en líneas "Etiqueta: valor" legibles.
List<MapEntry<String, String>> _lineasDetalle(dynamic bruto, bool en) {
  if (bruto == null) return [];
  dynamic d;
  try {
    d = jsonDecode('$bruto');
  } catch (_) {
    return [MapEntry(en ? 'Details' : 'Detalle', '$bruto')];
  }
  if (d is! Map) return [];

  final lineas = <MapEntry<String, String>>[];
  d.forEach((k, v) {
    final clave = '$k';
    if (clave == 'cambios') {
      if (v is Map) {
        v.forEach((campo, cambio) {
          if (cambio is Map) {
            lineas.add(MapEntry(
              _traducir(_mapaEtiquetas, '$campo', en),
              '${cambio['antes']}  →  ${cambio['despues']}',
            ));
          }
        });
      }
      return; // "cambios" vacío: no se muestra nada
    }
    lineas.add(MapEntry(_traducir(_mapaEtiquetas, clave, en), _formatearValor(clave, v, en)));
  });
  return lineas;
}

String _fechaBonita(dynamic bruto, bool en, {bool conSegundos = false}) {
  final d = DateTime.tryParse('$bruto'.replaceFirst(' ', 'T'));
  if (d == null) return '$bruto';
  final meses = en ? _mesesEn : _mesesEs;
  String dos(int n) => n.toString().padLeft(2, '0');
  final hora = '${dos(d.hour)}:${dos(d.minute)}${conSegundos ? ':${dos(d.second)}' : ''}';
  return '${d.day} ${meses[d.month - 1]} ${d.year} · $hora';
}

IconData _iconoModulo(String m) {
  switch (m) {
    case 'auth':
      return Icons.login;
    case 'politica':
      return Icons.policy_outlined;
    case 'usuarios':
      return Icons.people_outline;
    case 'citas':
      return Icons.calendar_today_outlined;
    case 'disponibilidad':
      return Icons.event_available_outlined;
    case 'sos':
      return Icons.error_outline;
    case 'autoevaluacion':
      return Icons.checklist_outlined;
    case 'reportes':
      return Icons.bar_chart_outlined;
    case 'backup':
      return Icons.storage_outlined;
    case 'auditoria':
      return Icons.fact_check_outlined;
    default:
      return Icons.history;
  }
}

MaterialColor _colorResultado(String r) =>
    r == 'ok' ? Colors.green : (r == 'denegado' ? Colors.orange : Colors.red);

/// Pantalla del Admin para consultar los logs del sistema (tabla audit_logs).
/// Solo lectura: los logs no se pueden editar ni borrar desde la app.
class AuditoriaAdminScreen extends StatefulWidget {
  final int adminId;
  const AuditoriaAdminScreen({super.key, required this.adminId});

  @override
  State<AuditoriaAdminScreen> createState() => _AuditoriaAdminScreenState();
}

class _AuditoriaAdminScreenState extends State<AuditoriaAdminScreen> {
  static const int _porPagina = 25;

  bool _cargando = true;
  String? _error;
  List<dynamic> _logs = [];
  int _total = 0;
  int _pagina = 1;
  List<String> _modulosDisponibles = [];
  List<String> _accionesDisponibles = [];

  String? _desde;
  String? _hasta;
  String? _modulo;
  String? _accion;
  String? _resultado;
  final TextEditingController _usuarioCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    super.dispose();
  }

  bool get _esIngles => Localizations.localeOf(context).languageCode == 'en';
  String _t(String es, String en) => _esIngles ? en : es;

  String _fmtFecha(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    final cuerpo = <String, dynamic>{
      'admin_id': widget.adminId,
      'pagina': _pagina,
      'por_pagina': _porPagina,
      if (_desde != null) 'desde': _desde,
      if (_hasta != null) 'hasta': _hasta,
      if (_usuarioCtrl.text.trim().isNotEmpty) 'usuario': _usuarioCtrl.text.trim(),
      if (_modulo != null) 'modulo': _modulo,
      if (_accion != null) 'accion': _accion,
      if (_resultado != null) 'resultado': _resultado,
    };

    try {
      final r = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/audit_logs_listar.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cuerpo),
      );
      final datos = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
      if (!mounted) return;

      if (r.statusCode != 200) {
        setState(() => _error = datos['error']?.toString() ?? _t('Error al cargar los registros.', 'Error loading the records.'));
        return;
      }

      setState(() {
        _logs = (datos['logs'] as List<dynamic>?) ?? [];
        _total = int.tryParse('${datos['total']}') ?? 0;
        _modulosDisponibles = ((datos['modulos'] as List<dynamic>?) ?? []).map((e) => '$e').toList();
        _accionesDisponibles = ((datos['acciones'] as List<dynamic>?) ?? []).map((e) => '$e').toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _t('No se pudo conectar con el servidor.', 'Could not connect to the server.'));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _buscar() {
    _pagina = 1;
    _cargar();
  }

  void _limpiar() {
    _desde = null;
    _hasta = null;
    _modulo = null;
    _accion = null;
    _resultado = null;
    _usuarioCtrl.clear();
    _pagina = 1;
    _cargar();
  }

  Future<void> _elegirFecha(bool esDesde) async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: hoy,
      firstDate: DateTime(2026),
      lastDate: DateTime(hoy.year + 1),
    );
    if (elegida == null) return;
    setState(() {
      if (esDesde) {
        _desde = _fmtFecha(elegida);
      } else {
        _hasta = _fmtFecha(elegida);
      }
    });
  }

  Widget _desplegable(
    String etiqueta,
    String? valor,
    List<String> opciones,
    String Function(String) etiquetaDe,
    ValueChanged<String?> alCambiar, {
    double ancho = 190,
  }) {
    final ordenadas = [...opciones]..sort((a, b) => etiquetaDe(a).compareTo(etiquetaDe(b)));
    return SizedBox(
      width: ancho,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: etiqueta,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String?>(
            value: valor,
            isDense: true,
            isExpanded: true,
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(_t('Todos', 'All'))),
              for (final o in ordenadas)
                DropdownMenuItem<String?>(
                  value: o,
                  child: Text(etiquetaDe(o), overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: alCambiar,
          ),
        ),
      ),
    );
  }

  Widget _chipResultado(String r) {
    final c = _colorResultado(r);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: c.shade100, borderRadius: BorderRadius.circular(12)),
      child: Text(
        _traducir(_mapaResultados, r, _esIngles),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.shade900),
      ),
    );
  }

  String _quienTexto(dynamic l) {
    final correo = l['correo'];
    final rol = l['rol'];
    final partes = <String>[];
    if (correo != null && '$correo'.isNotEmpty) {
      partes.add('$correo');
    } else if (l['usuario_id'] != null) {
      partes.add('ID ${l['usuario_id']}');
    } else {
      partes.add(_t('Usuario sin identificar', 'Unidentified user'));
    }
    if (rol != null && '$rol'.isNotEmpty) partes.add(_traducirValor('$rol', _esIngles));
    return partes.join('  ·  ');
  }

  String _ipTexto(dynamic ip) {
    if (ip == null || '$ip'.isEmpty) return '-';
    if ('$ip' == '::1' || '$ip' == '127.0.0.1') {
      return _t('Este equipo (localhost)', 'This computer (localhost)');
    }
    return '$ip';
  }

  Widget _tarjetaLog(dynamic l) {
    final en = _esIngles;
    final colores = Theme.of(context).colorScheme;
    final res = '${l['resultado'] ?? 'ok'}';
    final c = _colorResultado(res);
    final lineas = _lineasDetalle(l['detalle'], en);
    final resumen = lineas.take(3).map((e) => '${e.key}: ${e.value}').join('   ·   ');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _verDetalle(l),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: c.shade100,
                child: Icon(_iconoModulo('${l['modulo']}'), size: 18, color: c.shade800),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _traducir(_mapaAcciones, '${l['accion']}', en),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(_quienTexto(l), style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant)),
                    if (resumen.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(resumen, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _chipResultado(res),
                  const SizedBox(height: 6),
                  Text(_fechaBonita(l['fecha'], en), style: TextStyle(fontSize: 11, color: colores.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verDetalle(dynamic l) {
    final en = _esIngles;
    final colores = Theme.of(context).colorScheme;
    final lineas = _lineasDetalle(l['detalle'], en);
    final res = '${l['resultado'] ?? 'ok'}';

    Widget fila(String k, Widget v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 130, child: Text(k, style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant))),
              Expanded(child: v),
            ],
          ),
        );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_traducir(_mapaAcciones, '${l['accion']}', en)),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fila(_t('Fecha', 'Date'), Text(_fechaBonita(l['fecha'], en, conSegundos: true))),
                fila(_t('Usuario', 'User'), SelectableText(_quienTexto(l))),
                fila(_t('Módulo', 'Module'), Text(_traducir(_mapaModulos, '${l['modulo']}', en))),
                fila(_t('Resultado', 'Result'), Align(alignment: Alignment.centerLeft, child: _chipResultado(res))),
                fila(_t('Dirección IP', 'IP address'), Text(_ipTexto(l['ip']))),
                if (lineas.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(_t('Detalle', 'Details'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  for (final e in lineas) fila(e.key, SelectableText(e.value)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(_t('Cerrar', 'Close'))),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _elegirFecha(true),
              icon: const Icon(Icons.event, size: 16),
              label: Text(_desde == null ? _t('Desde', 'From') : '${_t('Desde', 'From')}: $_desde'),
            ),
            OutlinedButton.icon(
              onPressed: () => _elegirFecha(false),
              icon: const Icon(Icons.event, size: 16),
              label: Text(_hasta == null ? _t('Hasta', 'To') : '${_t('Hasta', 'To')}: $_hasta'),
            ),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _usuarioCtrl,
                decoration: InputDecoration(
                  labelText: _t('Usuario (correo o ID)', 'User (email or ID)'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _buscar(),
              ),
            ),
            _desplegable(_t('Módulo', 'Module'), _modulo, _modulosDisponibles,
                (o) => _traducir(_mapaModulos, o, _esIngles), (v) => setState(() => _modulo = v)),
            _desplegable(_t('Acción', 'Action'), _accion, _accionesDisponibles,
                (o) => _traducir(_mapaAcciones, o, _esIngles), (v) => setState(() => _accion = v),
                ancho: 260),
            _desplegable(_t('Resultado', 'Result'), _resultado, const ['ok', 'error', 'denegado'],
                (o) => _traducir(_mapaResultados, o, _esIngles), (v) => setState(() => _resultado = v),
                ancho: 150),
            FilledButton.icon(
              onPressed: _buscar,
              icon: const Icon(Icons.search, size: 16),
              label: Text(_t('Buscar', 'Search')),
            ),
            TextButton(onPressed: _limpiar, child: Text(_t('Limpiar', 'Clear'))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final totalPaginas = _total == 0 ? 1 : ((_total + _porPagina - 1) ~/ _porPagina);

    Widget cuerpo;
    if (_cargando) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      cuerpo = Center(child: Text(_error!, style: TextStyle(color: colores.error)));
    } else if (_logs.isEmpty) {
      cuerpo = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: colores.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(_t('No hay registros con esos filtros.', 'No records match those filters.'),
                style: TextStyle(color: colores.onSurfaceVariant)),
          ],
        ),
      );
    } else {
      cuerpo = ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, i) => _tarjetaLog(_logs[i]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _filtros(),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$_total ${_t('registros', 'records')}',
              style: TextStyle(fontSize: 12, color: colores.onSurfaceVariant),
            ),
            const Spacer(),
            IconButton(
              tooltip: _t('Actualizar', 'Refresh'),
              icon: const Icon(Icons.refresh),
              onPressed: _cargando ? null : _cargar,
            ),
          ],
        ),
        Expanded(child: cuerpo),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: _t('Anterior', 'Previous'),
              icon: const Icon(Icons.chevron_left),
              onPressed: _pagina > 1 && !_cargando
                  ? () {
                      _pagina--;
                      _cargar();
                    }
                  : null,
            ),
            Text('${_t('Página', 'Page')} $_pagina / $totalPaginas'),
            IconButton(
              tooltip: _t('Siguiente', 'Next'),
              icon: const Icon(Icons.chevron_right),
              onPressed: _pagina < totalPaginas && !_cargando
                  ? () {
                      _pagina++;
                      _cargar();
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
