import 'package:flutter/widgets.dart';
import 'package:sereo_app/l10n_ext.dart';

/// Traduce la clasificación PHQ-9 que llega del servidor (siempre en español).
/// Úsala donde se muestre la clasificación: textoClasificacion(context, valor)
String textoClasificacion(BuildContext context, String c) {
  final t = context.t;
  switch (c) {
    case 'Minimo':
      return t.nivelMinimo;
    case 'Leve':
      return t.nivelLeve;
    case 'Moderado':
      return t.nivelModerado;
    case 'Moderadamente severo':
      return t.nivelModeradamenteSevero;
    case 'Severo':
      return t.nivelSevero;
    default:
      return c;
  }
}

/// Traduce el estado de una cita o solicitud SOS ('pendiente', 'atendida'...).
/// Úsala así: textoEstadoL10n(context, c['estado'])
String textoEstadoL10n(BuildContext context, String estado) {
  final t = context.t;
  switch (estado) {
    case 'pendiente':
      return t.estadoPendiente;
    case 'en_proceso':
      return t.estadoEnProceso;
    case 'confirmada':
      return t.estadoConfirmada;
    case 'reagendada':
      return t.estadoReagendada;
    case 'atendida':
      return t.estadoAtendida;
    case 'cancelada':
      return t.estadoCancelada;
    default:
      return estado;
  }
}
