// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SEREO';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get sos => 'Ayuda SOS';

  @override
  String get appointments => 'Citas';

  @override
  String get language => 'Idioma';

  @override
  String welcomeUser(String name) {
    return 'Bienvenido, $name';
  }

  @override
  String get err_invalid_credentials => 'Correo o contraseña incorrectos';

  @override
  String get appSubtitle => 'Acompañamiento psicológico universitario';

  @override
  String get institutionalEmail => 'Correo institucional';

  @override
  String get emailHint => 'usuario';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get signUpLink => 'Regístrate';

  @override
  String get studentsOnlyNote =>
      'Solo estudiantes pueden registrarse aquí. El personal de Bienestar y Administración recibe su cuenta directamente.';

  @override
  String get err_captcha => 'La verificación no es correcta. Intenta de nuevo.';

  @override
  String err_connection(String detail) {
    return 'Error de conexión: $detail';
  }

  @override
  String get agendaBienestarDesactivarEstaFranja => '¿Desactivar esta franja?';

  @override
  String agendaBienestarVasADesactivarLa(
    Object fecha,
    Object horaInicio,
    Object horaFin,
  ) {
    return 'Vas a desactivar la disponibilidad del $fecha de $horaInicio a $horaFin.\n\nYa no aparecerá como opción para que los estudiantes agenden citas ahí, pero quedará registrada en el historial.';
  }

  @override
  String get agendaBienestarCancelar => 'Cancelar';

  @override
  String get agendaBienestarSiDesactivar => 'Sí, desactivar';

  @override
  String get agendaBienestarCancelarEstaCita => '¿Cancelar esta cita?';

  @override
  String agendaBienestarVasACancelarLa(
    Object estudianteNombre,
    Object fechaHora,
  ) {
    return 'Vas a cancelar la cita de $estudianteNombre ($fechaHora).';
  }

  @override
  String get agendaBienestarNoVolver => 'No, volver';

  @override
  String get agendaBienestarSiCancelar => 'Sí, cancelar';

  @override
  String get agendaBienestarAgregar => 'Agregar';

  @override
  String get agendaBienestarNoHasDefinidoDisponibilidad =>
      'No has definido disponibilidad este día.';

  @override
  String get agendaBienestarDesactivar => 'Desactivar';

  @override
  String get agendaBienestarNoTienesCitasEste => 'No tienes citas este día.';

  @override
  String get agendaBienestarConfirmar => 'Confirmar';

  @override
  String get agendaBienestarMarcarAtendida => 'Marcar atendida';

  @override
  String get agendaBienestarReagendar => 'Reagendar';

  @override
  String get autoevaluacionEstudianteRespondeTodasLasPreguntas =>
      'Responde todas las preguntas antes de continuar.';

  @override
  String autoevaluacionEstudianteErrorDeConexion(Object e) {
    return 'Error de conexión: $e';
  }

  @override
  String get autoevaluacionEstudianteResultadoDeTuAutoevaluacion =>
      'Resultado de tu autoevaluación';

  @override
  String autoevaluacionEstudiantePuntaje27(Object puntaje) {
    return 'Puntaje: $puntaje / 27';
  }

  @override
  String autoevaluacionEstudianteNivel(Object clasificacion) {
    return 'Nivel: $clasificacion';
  }

  @override
  String get autoevaluacionEstudianteUnaDeTusRespuestas =>
      'Una de tus respuestas indica que podrías estar pasando por un momento difícil. No estás solo(a) - te recomendamos hablar con Bienestar Universitario lo antes posible, o usar el botón de Solicitud prioritaria (SOS) desde la pantalla principal.';

  @override
  String get autoevaluacionEstudianteEsteResultadoEsUn =>
      'Este resultado es un tamizaje, no un diagnóstico. Si sientes que necesitas apoyo, Bienestar Universitario está disponible para ti.';

  @override
  String get autoevaluacionEstudianteEntendido => 'Entendido';

  @override
  String get autoevaluacionEstudianteAutoevaluacion => 'Autoevaluación';

  @override
  String get autoevaluacionEstudiantePhq9 => 'PHQ-9';

  @override
  String get autoevaluacionEstudianteTestBreveDeTamizaje =>
      'Test breve de tamizaje, usado ampliamente en entornos clínicos para identificar señales de ánimo bajo en las últimas 2 semanas. Toma menos de 3 minutos.';

  @override
  String get autoevaluacionEstudianteComenzarAutoevaluacion =>
      'Comenzar autoevaluación';

  @override
  String get autoevaluacionEstudianteMiHistorial => 'Mi historial';

  @override
  String get autoevaluacionEstudianteAunNoHasRealizado =>
      'Aún no has realizado ninguna autoevaluación.';

  @override
  String get autoevaluacionEstudianteDuranteLasUltimas2 =>
      'Durante las últimas 2 semanas, ¿con qué frecuencia te ha molestado cada uno de los siguientes problemas?';

  @override
  String get autoevaluacionEstudianteEnviarRespuestas => 'Enviar respuestas';

  @override
  String get autoevaluacionesBienestarNoHayResultadosEn =>
      'No hay resultados en este filtro.';

  @override
  String get backupRestoreAdminNoSePudoGenerar =>
      'No se pudo generar el backup.';

  @override
  String get backupRestoreAdminRestaurarBaseDeDatos =>
      '⚠️ Restaurar base de datos';

  @override
  String backupRestoreAdminVasARestaurarDesde(Object nombreArchivo) {
    return 'Vas a restaurar desde el archivo \"$nombreArchivo\".\n\nEsto BORRA todos los datos actuales (usuarios, citas, SOS, autoevaluaciones, todo) y los reemplaza por los del backup. Esta acción no se puede deshacer.';
  }

  @override
  String get backupRestoreAdminEntiendoContinuar => 'Entiendo, continuar';

  @override
  String get backupRestoreAdminConfirmacionFinal => 'Confirmación final';

  @override
  String get backupRestoreAdminEscribeRestaurarEnMayusculas =>
      'Escribe RESTAURAR (en mayúsculas) para confirmar:';

  @override
  String get backupRestoreAdminRestaurarAhora => 'Restaurar ahora';

  @override
  String get backupRestoreAdminBaseDeDatosRestaurada =>
      'Base de datos restaurada correctamente.';

  @override
  String get backupRestoreAdminGenerarBackup => 'Generar backup';

  @override
  String get backupRestoreAdminDescargaUnArchivoSql =>
      'Descarga un archivo .sql con toda la información actual.';

  @override
  String get backupRestoreAdminRestaurarBackup => 'Restaurar backup';

  @override
  String get backupRestoreAdminReemplazaTodosLosDatos =>
      'Reemplaza TODOS los datos actuales por los de un archivo .sql.';

  @override
  String get backupRestoreAdminRecomendacionGeneraUnBackup =>
      'Recomendación: genera un backup regularmente (por ejemplo, antes de cada entrega), y guárdalo en un lugar seguro fuera del computador (correo, USB, nube).';

  @override
  String get captchaWidgetOtraOperacion => 'Otra operación';

  @override
  String get citasBienestarNoHayCitasEn => 'No hay citas en este filtro.';

  @override
  String get citasEstudianteConfirmarCita => 'Confirmar cita';

  @override
  String get citasEstudianteSolicitar => 'Solicitar';

  @override
  String citasEstudianteVasACancelarTu(Object profesional, Object fechaHora) {
    return 'Vas a cancelar tu cita con $profesional ($fechaHora).';
  }

  @override
  String get citasEstudianteAgendarCita => 'Agendar cita';

  @override
  String get citasEstudianteNoHayHorariosLibres =>
      'No hay horarios libres este día.';

  @override
  String get citasEstudianteMisCitas => 'Mis citas';

  @override
  String get citasEstudianteAunNoTienesCitas =>
      'Aún no tienes citas agendadas.';

  @override
  String get disponibilidadBienestarAgregarFranjaDeDisponibilidad =>
      'Agregar franja de disponibilidad';

  @override
  String get disponibilidadBienestarMisFranjas => 'Mis franjas';

  @override
  String get disponibilidadBienestarAunNoHasAgregado =>
      'Aún no has agregado disponibilidad.';

  @override
  String homeEstudianteModuloEnConstruccion(Object modulo) {
    return '$modulo — módulo en construcción';
  }

  @override
  String homeEstudianteHola(Object nombreEstudiante) {
    return 'Hola, $nombreEstudiante';
  }

  @override
  String get homeEstudianteCerrarSesion => 'Cerrar sesión';

  @override
  String get homeEstudianteSolicitudPrioritariaSos =>
      'Solicitud prioritaria (SOS)';

  @override
  String get homeEstudianteSiNecesitasAyudaUrgente =>
      'Si necesitas ayuda urgente';

  @override
  String get homeEstudianteDiarioEmocional => 'Diario emocional';

  @override
  String get homeEstudianteMiPerfil => 'Mi perfil';

  @override
  String get homeStaffDashboard => 'Dashboard';

  @override
  String get homeStaffUsuarios => 'Usuarios';

  @override
  String get homeStaffConfiguracion => 'Configuración';

  @override
  String get homeStaffSolicitudes => 'Solicitudes';

  @override
  String get homeStaffAutoevaluaciones => 'Autoevaluaciones';

  @override
  String get homeStaffAgenda => 'Agenda';

  @override
  String get homeStaffReportes => 'Reportes';

  @override
  String get homeStaffActualizar => 'Actualizar';

  @override
  String get homeStaffEsteModuloEstaEn => 'Este módulo está en construcción';

  @override
  String get inactivityGuardSesionBloqueadaPorInactividad =>
      'Sesión bloqueada por inactividad';

  @override
  String get inactivityGuardDesbloquear => 'Desbloquear';

  @override
  String get politicaPoliticaDeTratamientoDe =>
      'Política de tratamiento de datos';

  @override
  String get politicaPoliticaDeTratamientoDe2 =>
      'POLÍTICA DE TRATAMIENTO DE DATOS PERSONALES — SEREO';

  @override
  String get politicaHeLeidoYAcepto =>
      'He leído y acepto la política de tratamiento de datos personales.';

  @override
  String get politicaAceptarYContinuar => 'Aceptar y continuar';

  @override
  String get registerCrearCuentaDeEstudiante => 'Crear cuenta de estudiante';

  @override
  String get registerRegistrateConTuCorreo =>
      'Regístrate con tu correo institucional';

  @override
  String get registerNombreCompleto => 'Nombre completo';

  @override
  String get registerAnaMariaGomez => 'Ana María Gómez';

  @override
  String get registerProgramaAcademico => 'Programa académico';

  @override
  String get registerSeleccionaTuPrograma => 'Selecciona tu programa';

  @override
  String get registerAdministracionDeEmpresas => 'Administración de Empresas';

  @override
  String get registerContaduriaPublica => 'Contaduría Pública';

  @override
  String get registerZootecnia => 'Zootecnia';

  @override
  String get registerIngenieriaDeSistemasY =>
      'Ingeniería de Sistemas y Computación';

  @override
  String get registerIngenieriaElectronica => 'Ingeniería Electrónica';

  @override
  String get registerCienciasSociales => 'Ciencias Sociales';

  @override
  String get registerEducacionFisica => 'Educación Física';

  @override
  String get registerMinimo8Caracteres => 'Mínimo 8 caracteres';

  @override
  String get registerConfirmarContrasena => 'Confirmar contraseña';

  @override
  String get registerRepiteTuContrasena => 'Repite tu contraseña';

  @override
  String get registerCrearCuenta => 'Crear cuenta';

  @override
  String get reportesBienestarNoSePudoAbrir =>
      'No se pudo abrir el reporte. Verifica tu conexión.';

  @override
  String get reportesBienestarExportarAExcelCsv => 'Exportar a Excel (CSV)';

  @override
  String get reportesBienestarSeDescargaUnArchivo =>
      'Se descarga un archivo que abre directamente en Excel, listo para filtrar y analizar.';

  @override
  String get reportesBienestarEstadisticasPorProgramaAcademico =>
      'Estadísticas por programa académico';

  @override
  String get reportesBienestarSosCitasYAutoevaluaciones =>
      'SOS, citas y autoevaluaciones agrupadas por carrera — el reporte más útil para identificar dónde hay mayor necesidad de acompañamiento.';

  @override
  String get reportesBienestarHistorialDeSolicitudesSos =>
      'Historial de solicitudes SOS';

  @override
  String get reportesBienestarListadoCompletoConEstudiante =>
      'Listado completo con estudiante, estado y fechas.';

  @override
  String get reportesBienestarHistorialDeCitas => 'Historial de citas';

  @override
  String get reportesBienestarTodasLasCitasAgendadas =>
      'Todas las citas agendadas, con su estado y profesional asignado.';

  @override
  String get reportesBienestarResumenEjecutivoPdf => 'Resumen ejecutivo (PDF)';

  @override
  String get reportesBienestarSeAbreUnaPagina =>
      'Se abre una página lista para imprimir o guardar como PDF (Ctrl+P), ideal para presentar en una reunión.';

  @override
  String get reportesBienestarResumenEjecutivoDeIndicadores =>
      'Resumen ejecutivo de indicadores';

  @override
  String get reportesBienestarUnVistazoGeneralTotales =>
      'Un vistazo general: totales, SOS pendientes, y promedio del PHQ-9 por programa.';

  @override
  String get sosBienestarNoHaySolicitudesEn =>
      'No hay solicitudes en este filtro.';

  @override
  String get sosBienestarTomarCaso => 'Tomar caso';

  @override
  String get sosEstudianteSolicitudEnviadaBienestarLa =>
      'Solicitud enviada. Bienestar la atenderá pronto.';

  @override
  String get sosEstudianteSiEstasEnUna =>
      'Si estás en una situación de crisis o riesgo inmediato, comunícate directamente con la línea de emergencias. Este formulario notifica a Bienestar, pero puede tardar unos minutos en ser leído.';

  @override
  String get sosEstudianteNuevaSolicitud => 'Nueva solicitud';

  @override
  String get sosEstudianteQueNecesitasBreve => '¿Qué necesitas? (breve)';

  @override
  String get sosEstudianteTelefonoDeContactoOpcional =>
      'Teléfono de contacto (opcional)';

  @override
  String get sosEstudianteEnviarSolicitud => 'Enviar solicitud';

  @override
  String get sosEstudianteMisSolicitudesAnteriores =>
      'Mis solicitudes anteriores';

  @override
  String get sosEstudianteAunNoHasEnviado =>
      'Aún no has enviado ninguna solicitud.';

  @override
  String get usuariosAdminExportarAExcel => 'Exportar a Excel';

  @override
  String get usuariosAdminNuevaCuenta => 'Nueva cuenta';

  @override
  String get usuariosAdminNoHayUsuariosEn => 'No hay usuarios en este filtro.';

  @override
  String get usuariosAdminContrasenaMin8Caracteres =>
      'Contraseña (mín. 8 caracteres)';

  @override
  String get usuariosAdminRol => 'Rol';

  @override
  String get usuariosAdminBienestar => 'Bienestar';

  @override
  String get usuariosAdminAdmin => 'Admin';

  @override
  String get usuariosAdminGuardar => 'Guardar';

  @override
  String agendaBienestarDisponibilidadFecha(Object fecha) {
    return 'Disponibilidad - $fecha';
  }

  @override
  String agendaBienestarCitasFecha(Object fecha) {
    return 'Citas - $fecha';
  }

  @override
  String get agendaBienestarHoraDeInicio => 'HORA DE INICIO';

  @override
  String get agendaBienestarHoraDeFin => 'HORA DE FIN';

  @override
  String get filtroTodos => 'Todos';

  @override
  String get nivelSevero => 'Severo';

  @override
  String get nivelModSevero => 'Mod. severo';

  @override
  String get nivelModerado => 'Moderado';

  @override
  String get nivelLeve => 'Leve';

  @override
  String get nivelMinimo => 'Mínimo';

  @override
  String get filtroPendientes => 'Pendientes';

  @override
  String get filtroConfirmadas => 'Confirmadas';

  @override
  String get filtroReagendadas => 'Reagendadas';

  @override
  String get filtroAtendidas => 'Atendidas';

  @override
  String get filtroCanceladas => 'Canceladas';

  @override
  String get filtroTodas => 'Todas';

  @override
  String citasEstudianteHorariosDisponiblesFecha(Object fecha) {
    return 'Horarios disponibles - $fecha';
  }

  @override
  String get citasEstudiantePorAsignar => 'Por asignar';

  @override
  String get citasEstudianteElProfesionalAsignado => 'el profesional asignado';

  @override
  String get disponibilidadBienestarCompletaTodosLosCampos =>
      'Completa fecha, hora inicio y hora fin.';

  @override
  String get disponibilidadBienestarElegirFecha => 'Elegir fecha';

  @override
  String get disponibilidadBienestarHoraInicio => 'Hora inicio';

  @override
  String get disponibilidadBienestarHoraFin => 'Hora fin';

  @override
  String get disponibilidadBienestarActiva => 'Activa';

  @override
  String get disponibilidadBienestarDesactivada => 'Desactivada';

  @override
  String get temaClaro => 'Tema claro';

  @override
  String get temaOscuro => 'Tema oscuro';

  @override
  String get perfil => 'Perfil';

  @override
  String get homeStaffSolicitudesPendientes => 'Solicitudes pendientes';

  @override
  String get homeStaffCitasDeHoy => 'Citas de hoy';

  @override
  String get homeStaffCitasEstaSemana => 'Citas esta semana';

  @override
  String get homeStaffEstudiantes => 'Estudiantes';

  @override
  String get homeStaffAdministradores => 'Administradores';

  @override
  String get inactivityGuardSesionCerradaInactividad =>
      'Se cerró tu sesión por inactividad.';

  @override
  String get inactivityGuardSesionOtroDispositivo =>
      'Tu sesión fue cerrada porque iniciaste sesión con esta cuenta en otro dispositivo.';

  @override
  String get inactivityGuardNoSePudoVerificar =>
      'No se pudo verificar la contraseña.';

  @override
  String get registerSeleccionaTuProgramaAcademico =>
      'Selecciona tu programa académico.';

  @override
  String get filtroEnProceso => 'En proceso';

  @override
  String get sosEstudianteNoSePudoCargar => 'No se pudo cargar tu historial.';

  @override
  String get sosEstudianteCuentanosBrevemente =>
      'Cuéntanos brevemente qué necesitas.';

  @override
  String get usuariosAdminEditarUsuario => 'Editar usuario';

  @override
  String get opcionNunca => 'Nunca';

  @override
  String get opcionVariosDias => 'Varios días';

  @override
  String get opcionMasDeLaMitad => 'Más de la mitad de los días';

  @override
  String get opcionCasiTodos => 'Casi todos los días';

  @override
  String get nivelModeradamenteSevero => 'Moderadamente severo';

  @override
  String get phq9Pregunta1 => 'Poco interés o placer en hacer las cosas';

  @override
  String get phq9Pregunta2 =>
      'Sentirse desanimado(a), deprimido(a) o sin esperanza';

  @override
  String get phq9Pregunta3 =>
      'Dificultad para dormir o permanecer dormido(a), o dormir demasiado';

  @override
  String get phq9Pregunta4 => 'Sentirse cansado(a) o tener poca energía';

  @override
  String get phq9Pregunta5 => 'Poco apetito o comer en exceso';

  @override
  String get phq9Pregunta6 =>
      'Sentirse mal consigo mismo(a), o sentir que es un fracaso o que ha quedado mal con usted mismo(a) o con su familia';

  @override
  String get phq9Pregunta7 =>
      'Dificultad para concentrarse en cosas como leer el periódico o ver televisión';

  @override
  String get phq9Pregunta8 =>
      'Moverse o hablar tan lentamente que otras personas podrían notarlo, o lo contrario: estar tan inquieto(a) o agitado(a) que se ha estado moviendo mucho más de lo normal';

  @override
  String get phq9Pregunta9 =>
      'Pensamientos de que estaría mejor muerto(a) o de hacerse daño de alguna manera';

  @override
  String citasEstudianteVasASolicitar(
    Object profesional,
    Object fecha,
    Object hora,
  ) {
    return 'Vas a solicitar una cita con $profesional\n$fecha a las $hora.\n\nBienestar deberá confirmarla.';
  }

  @override
  String get estadoPendiente => 'Pendiente';

  @override
  String get estadoEnProceso => 'En proceso';

  @override
  String get estadoConfirmada => 'Confirmada';

  @override
  String get estadoReagendada => 'Reagendada';

  @override
  String get estadoAtendida => 'Atendida';

  @override
  String get estadoCancelada => 'Cancelada';

  @override
  String get calendarioMes => 'Mes';

  @override
  String get calendarioDosSemanas => '2 semanas';

  @override
  String get calendarioSemana => 'Semana';

  @override
  String citaFecha(Object fecha) {
    return 'Fecha: $fecha';
  }

  @override
  String citaMotivo(Object motivo) {
    return 'Motivo: $motivo';
  }

  @override
  String sosTelefono(Object telefono) {
    return 'Tel: $telefono';
  }

  @override
  String get politicaSeccion1Titulo => '1. Responsable del tratamiento';

  @override
  String get politicaSeccion1Texto =>
      'SEREO es una plataforma desarrollada para el área de Bienestar Universitario de la Universidad de Cundinamarca, orientada al acompañamiento psicológico y emocional de su comunidad estudiantil. El área de Bienestar Universitario actúa como responsable del tratamiento de los datos personales recolectados a través de esta aplicación.';

  @override
  String get politicaSeccion2Titulo => '2. Datos que se recolectan';

  @override
  String get politicaSeccion2Texto =>
      '• Datos de identificación: nombre completo, correo institucional, programa académico.\n• Credenciales de acceso: contraseña (almacenada de forma cifrada).\n• Datos sensibles de salud mental: solicitudes de atención prioritaria (SOS), diario emocional, autoevaluaciones psicológicas, e historial de citas con profesionales de Bienestar.\n• Datos técnicos: preferencias de la aplicación y datos de sesión.';

  @override
  String get politicaSeccion3Titulo => '3. Finalidad del tratamiento';

  @override
  String get politicaSeccion3Texto =>
      'Verificar tu identidad y pertenencia a la comunidad universitaria, gestionar solicitudes de atención psicológica y citas, permitir el seguimiento de tu bienestar emocional por parte de profesionales autorizados, y generar estadísticas agregadas y anónimas para apoyar decisiones institucionales.';

  @override
  String get politicaSeccion4Titulo =>
      '4. Confidencialidad de la información sensible';

  @override
  String get politicaSeccion4Texto =>
      'La información relacionada con tu estado emocional (diario, autoevaluaciones, solicitudes SOS) es confidencial. Solo el personal de Bienestar autorizado tiene acceso, y únicamente en el contexto necesario para brindarte atención. El personal administrativo del sistema NO tiene acceso a esta información bajo ninguna circunstancia.';

  @override
  String get politicaSeccion5Titulo => '5. Conservación de la información';

  @override
  String get politicaSeccion5Texto =>
      'La información no se elimina de forma permanente. Las solicitudes, citas y cuentas pueden cancelarse o desactivarse, pero se conservan con fines de trazabilidad, auditoría y continuidad del acompañamiento.';

  @override
  String get politicaSeccion6Titulo => '6. Tus derechos';

  @override
  String get politicaSeccion6Texto =>
      'Tienes derecho a conocer, actualizar y rectificar tus datos; ser informado sobre su uso; presentar quejas ante las autoridades competentes; y revocar tu autorización o solicitar la supresión de tus datos, cuando no exista un deber legal que lo impida.';

  @override
  String get politicaSeccion7Titulo => '7. Uso de almacenamiento local';

  @override
  String get politicaSeccion7Texto =>
      'SEREO utiliza almacenamiento local en tu dispositivo (similar a las cookies en aplicaciones web) para mantener tu sesión activa y recordar tus preferencias, como el tema visual. Esta información permanece únicamente en tu dispositivo.';

  @override
  String get politicaSeccion8Titulo => '8. Aceptación';

  @override
  String get politicaSeccion8Texto =>
      'El uso de SEREO requiere la aceptación expresa de esta política, de acuerdo con la Ley 1581 de 2012 y sus decretos reglamentarios.';

  @override
  String get passwordHintMin10 => 'Mínimo 10 caracteres';

  @override
  String get passwordReqTitle => 'Tu contraseña debe tener:';

  @override
  String get passwordReqLength => 'Al menos 10 caracteres';

  @override
  String get passwordReqUpper => 'Una letra mayúscula';

  @override
  String get passwordReqLower => 'Una letra minúscula';

  @override
  String get passwordReqNumber => 'Un número';

  @override
  String get passwordReqSpecial => 'Un carácter especial (por ejemplo ! @ # %)';

  @override
  String get passwordPolicyError =>
      'La contraseña no cumple los requisitos de seguridad.';

  @override
  String get passwordErrPersonal =>
      'No puede contener tu nombre ni parte de tu correo.';

  @override
  String get passwordErrCommon => 'Es una contraseña demasiado común.';

  @override
  String get perfilDatosBasicos => 'Datos básicos';

  @override
  String get perfilSemestre => 'Semestre';

  @override
  String get perfilTelefono => 'Teléfono';

  @override
  String get perfilOpcional => '(opcional)';

  @override
  String get perfilContactoEmergencia => 'Contacto de emergencia';

  @override
  String get perfilContactoNombre => 'Nombre del contacto';

  @override
  String get perfilContactoTelefono => 'Teléfono del contacto';

  @override
  String get perfilGuardarCambios => 'Guardar cambios';

  @override
  String get perfilGuardado => 'Perfil actualizado';

  @override
  String get perfilSeguridad => 'Seguridad';

  @override
  String get perfilCambiarContrasena => 'Cambiar contraseña';

  @override
  String get perfilContrasenaActual => 'Contraseña actual';

  @override
  String get perfilContrasenaNueva => 'Nueva contraseña';

  @override
  String get perfilConfirmarNueva => 'Confirmar nueva contraseña';

  @override
  String get perfilContrasenaCambiada => 'Contraseña actualizada correctamente';

  @override
  String perfilPoliticaAceptada(String fecha) {
    return 'Política de datos aceptada el $fecha';
  }

  @override
  String get perfilErrNombre =>
      'Escribe tu nombre completo (mínimo 3 caracteres).';

  @override
  String get perfilErrPrograma => 'Selecciona un programa académico válido.';

  @override
  String get perfilErrSemestre => 'El semestre debe estar entre 1 y 12.';

  @override
  String get perfilErrTelefono =>
      'Escribe un teléfono válido (de 7 a 15 dígitos).';

  @override
  String get perfilErrContactoIncompleto =>
      'Completa el nombre y el teléfono del contacto de emergencia.';

  @override
  String get perfilErrContactoNombre => 'El nombre del contacto no es válido.';

  @override
  String get perfilErrContrasenaActual =>
      'La contraseña actual no es correcta.';

  @override
  String get perfilErrNoCoinciden => 'Las contraseñas no coinciden.';

  @override
  String get perfilErrIgualActual =>
      'La nueva contraseña debe ser distinta de la actual.';

  @override
  String get perfilErrSesion =>
      'Tu sesión no es válida. Vuelve a iniciar sesión.';
}
