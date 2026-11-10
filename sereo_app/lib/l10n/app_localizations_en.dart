// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SEREO';

  @override
  String get login => 'Sign in';

  @override
  String get register => 'Sign up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get sos => 'SOS help';

  @override
  String get appointments => 'Appointments';

  @override
  String get language => 'Language';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String get err_invalid_credentials => 'Incorrect email or password';

  @override
  String get appSubtitle => 'University psychological support';

  @override
  String get institutionalEmail => 'Institutional email';

  @override
  String get emailHint => 'username';

  @override
  String get noAccount => 'Don’t have an account?';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get studentsOnlyNote =>
      'Only students can sign up here. Wellbeing and Administration staff receive their account directly.';

  @override
  String get err_captcha => 'The verification is incorrect. Please try again.';

  @override
  String err_connection(String detail) {
    return 'Connection error: $detail';
  }

  @override
  String get agendaBienestarDesactivarEstaFranja =>
      'Deactivate this time slot?';

  @override
  String agendaBienestarVasADesactivarLa(
    Object fecha,
    Object horaInicio,
    Object horaFin,
  ) {
    return 'You are about to deactivate the availability on $fecha from $horaInicio to $horaFin.\n\nIt will no longer appear as an option for students to book appointments there, but it will remain recorded in the history.';
  }

  @override
  String get agendaBienestarCancelar => 'Cancel';

  @override
  String get agendaBienestarSiDesactivar => 'Yes, deactivate';

  @override
  String get agendaBienestarCancelarEstaCita => 'Cancel this appointment?';

  @override
  String agendaBienestarVasACancelarLa(
    Object estudianteNombre,
    Object fechaHora,
  ) {
    return 'You are about to cancel the appointment of $estudianteNombre ($fechaHora).';
  }

  @override
  String get agendaBienestarNoVolver => 'No, go back';

  @override
  String get agendaBienestarSiCancelar => 'Yes, cancel';

  @override
  String get agendaBienestarAgregar => 'Add';

  @override
  String get agendaBienestarNoHasDefinidoDisponibilidad =>
      'You have not set any availability for this day.';

  @override
  String get agendaBienestarDesactivar => 'Deactivate';

  @override
  String get agendaBienestarNoTienesCitasEste =>
      'You have no appointments this day.';

  @override
  String get agendaBienestarConfirmar => 'Confirm';

  @override
  String get agendaBienestarMarcarAtendida => 'Mark as attended';

  @override
  String get agendaBienestarReagendar => 'Reschedule';

  @override
  String get autoevaluacionEstudianteRespondeTodasLasPreguntas =>
      'Answer all the questions before continuing.';

  @override
  String autoevaluacionEstudianteErrorDeConexion(Object e) {
    return 'Connection error: $e';
  }

  @override
  String get autoevaluacionEstudianteResultadoDeTuAutoevaluacion =>
      'Your self-assessment result';

  @override
  String autoevaluacionEstudiantePuntaje27(Object puntaje) {
    return 'Score: $puntaje / 27';
  }

  @override
  String autoevaluacionEstudianteNivel(Object clasificacion) {
    return 'Level: $clasificacion';
  }

  @override
  String get autoevaluacionEstudianteUnaDeTusRespuestas =>
      'One of your answers suggests you may be going through a difficult time. You are not alone - we recommend talking to University Wellbeing as soon as possible, or using the Priority Request (SOS) button on the main screen.';

  @override
  String get autoevaluacionEstudianteEsteResultadoEsUn =>
      'This result is a screening, not a diagnosis. If you feel you need support, University Wellbeing is available for you.';

  @override
  String get autoevaluacionEstudianteEntendido => 'Got it';

  @override
  String get autoevaluacionEstudianteAutoevaluacion => 'Self-assessment';

  @override
  String get autoevaluacionEstudiantePhq9 => 'PHQ-9';

  @override
  String get autoevaluacionEstudianteTestBreveDeTamizaje =>
      'A brief screening test, widely used in clinical settings to identify signs of low mood over the last 2 weeks. It takes less than 3 minutes.';

  @override
  String get autoevaluacionEstudianteComenzarAutoevaluacion =>
      'Start self-assessment';

  @override
  String get autoevaluacionEstudianteMiHistorial => 'My history';

  @override
  String get autoevaluacionEstudianteAunNoHasRealizado =>
      'You have not taken any self-assessment yet.';

  @override
  String get autoevaluacionEstudianteDuranteLasUltimas2 =>
      'Over the last 2 weeks, how often have you been bothered by each of the following problems?';

  @override
  String get autoevaluacionEstudianteEnviarRespuestas => 'Submit answers';

  @override
  String get autoevaluacionesBienestarNoHayResultadosEn =>
      'No results with this filter.';

  @override
  String get backupRestoreAdminNoSePudoGenerar =>
      'The backup could not be generated.';

  @override
  String get backupRestoreAdminRestaurarBaseDeDatos => '⚠️ Restore database';

  @override
  String backupRestoreAdminVasARestaurarDesde(Object nombreArchivo) {
    return 'You are about to restore from the file \"$nombreArchivo\".\n\nThis ERASES all current data (users, appointments, SOS, self-assessments, everything) and replaces it with the backup\'s data. This action cannot be undone.';
  }

  @override
  String get backupRestoreAdminEntiendoContinuar => 'I understand, continue';

  @override
  String get backupRestoreAdminConfirmacionFinal => 'Final confirmation';

  @override
  String get backupRestoreAdminEscribeRestaurarEnMayusculas =>
      'Type RESTAURAR (in capital letters) to confirm:';

  @override
  String get backupRestoreAdminRestaurarAhora => 'Restore now';

  @override
  String get backupRestoreAdminBaseDeDatosRestaurada =>
      'Database restored successfully.';

  @override
  String get backupRestoreAdminGenerarBackup => 'Generate backup';

  @override
  String get backupRestoreAdminDescargaUnArchivoSql =>
      'Downloads a .sql file with all the current information.';

  @override
  String get backupRestoreAdminRestaurarBackup => 'Restore backup';

  @override
  String get backupRestoreAdminReemplazaTodosLosDatos =>
      'Replaces ALL current data with the data from a .sql file.';

  @override
  String get backupRestoreAdminRecomendacionGeneraUnBackup =>
      'Recommendation: generate a backup regularly (for example, before each delivery) and keep it in a safe place outside the computer (email, USB drive, cloud).';

  @override
  String get captchaWidgetOtraOperacion => 'Another operation';

  @override
  String get citasBienestarNoHayCitasEn => 'No appointments with this filter.';

  @override
  String get citasEstudianteConfirmarCita => 'Confirm appointment';

  @override
  String get citasEstudianteSolicitar => 'Request';

  @override
  String citasEstudianteVasACancelarTu(Object profesional, Object fechaHora) {
    return 'You are about to cancel your appointment with $profesional ($fechaHora).';
  }

  @override
  String get citasEstudianteAgendarCita => 'Book appointment';

  @override
  String get citasEstudianteNoHayHorariosLibres =>
      'There are no free time slots this day.';

  @override
  String get citasEstudianteMisCitas => 'My appointments';

  @override
  String get citasEstudianteAunNoTienesCitas =>
      'You have no appointments booked yet.';

  @override
  String get disponibilidadBienestarAgregarFranjaDeDisponibilidad =>
      'Add availability slot';

  @override
  String get disponibilidadBienestarMisFranjas => 'My slots';

  @override
  String get disponibilidadBienestarAunNoHasAgregado =>
      'You have not added any availability yet.';

  @override
  String homeEstudianteModuloEnConstruccion(Object modulo) {
    return '$modulo — module under construction';
  }

  @override
  String homeEstudianteHola(Object nombreEstudiante) {
    return 'Hello, $nombreEstudiante';
  }

  @override
  String get homeEstudianteCerrarSesion => 'Sign out';

  @override
  String get homeEstudianteSolicitudPrioritariaSos => 'Priority request (SOS)';

  @override
  String get homeEstudianteSiNecesitasAyudaUrgente => 'If you need urgent help';

  @override
  String get homeEstudianteDiarioEmocional => 'Emotional journal';

  @override
  String get homeEstudianteMiPerfil => 'My profile';

  @override
  String get homeStaffDashboard => 'Dashboard';

  @override
  String get homeStaffUsuarios => 'Users';

  @override
  String get homeStaffConfiguracion => 'Settings';

  @override
  String get homeStaffSolicitudes => 'Requests';

  @override
  String get homeStaffAutoevaluaciones => 'Self-assessments';

  @override
  String get homeStaffAgenda => 'Schedule';

  @override
  String get homeStaffReportes => 'Reports';

  @override
  String get homeStaffActualizar => 'Refresh';

  @override
  String get homeStaffEsteModuloEstaEn => 'This module is under construction';

  @override
  String get inactivityGuardSesionBloqueadaPorInactividad =>
      'Session locked due to inactivity';

  @override
  String get inactivityGuardDesbloquear => 'Unlock';

  @override
  String get politicaPoliticaDeTratamientoDe => 'Data processing policy';

  @override
  String get politicaPoliticaDeTratamientoDe2 =>
      'PERSONAL DATA PROCESSING POLICY — SEREO';

  @override
  String get politicaHeLeidoYAcepto =>
      'I have read and accept the personal data processing policy.';

  @override
  String get politicaAceptarYContinuar => 'Accept and continue';

  @override
  String get registerCrearCuentaDeEstudiante => 'Create student account';

  @override
  String get registerRegistrateConTuCorreo =>
      'Sign up with your institutional email';

  @override
  String get registerNombreCompleto => 'Full name';

  @override
  String get registerAnaMariaGomez => 'Ana María Gómez';

  @override
  String get registerProgramaAcademico => 'Academic program';

  @override
  String get registerSeleccionaTuPrograma => 'Select your program';

  @override
  String get registerAdministracionDeEmpresas => 'Business Administration';

  @override
  String get registerContaduriaPublica => 'Public Accounting';

  @override
  String get registerZootecnia => 'Animal Science';

  @override
  String get registerIngenieriaDeSistemasY =>
      'Systems and Computer Engineering';

  @override
  String get registerIngenieriaElectronica => 'Electronic Engineering';

  @override
  String get registerCienciasSociales => 'Social Sciences';

  @override
  String get registerEducacionFisica => 'Physical Education';

  @override
  String get registerMinimo8Caracteres => 'Minimum 8 characters';

  @override
  String get registerConfirmarContrasena => 'Confirm password';

  @override
  String get registerRepiteTuContrasena => 'Repeat your password';

  @override
  String get registerCrearCuenta => 'Create account';

  @override
  String get reportesBienestarNoSePudoAbrir =>
      'The report could not be opened. Check your connection.';

  @override
  String get reportesBienestarExportarAExcelCsv => 'Export to Excel (CSV)';

  @override
  String get reportesBienestarSeDescargaUnArchivo =>
      'Downloads a file that opens directly in Excel, ready to filter and analyze.';

  @override
  String get reportesBienestarEstadisticasPorProgramaAcademico =>
      'Statistics by academic program';

  @override
  String get reportesBienestarSosCitasYAutoevaluaciones =>
      'SOS, appointments and self-assessments grouped by program — the most useful report for identifying where the need for support is greatest.';

  @override
  String get reportesBienestarHistorialDeSolicitudesSos =>
      'SOS request history';

  @override
  String get reportesBienestarListadoCompletoConEstudiante =>
      'Full list with student, status and dates.';

  @override
  String get reportesBienestarHistorialDeCitas => 'Appointment history';

  @override
  String get reportesBienestarTodasLasCitasAgendadas =>
      'All booked appointments, with their status and assigned professional.';

  @override
  String get reportesBienestarResumenEjecutivoPdf => 'Executive summary (PDF)';

  @override
  String get reportesBienestarSeAbreUnaPagina =>
      'Opens a page ready to print or save as PDF (Ctrl+P), ideal for presenting in a meeting.';

  @override
  String get reportesBienestarResumenEjecutivoDeIndicadores =>
      'Executive summary of indicators';

  @override
  String get reportesBienestarUnVistazoGeneralTotales =>
      'A general overview: totals, pending SOS requests, and average PHQ-9 by program.';

  @override
  String get sosBienestarNoHaySolicitudesEn => 'No requests with this filter.';

  @override
  String get sosBienestarTomarCaso => 'Take case';

  @override
  String get sosEstudianteSolicitudEnviadaBienestarLa =>
      'Request sent. Wellbeing will attend to it soon.';

  @override
  String get sosEstudianteSiEstasEnUna =>
      'If you are in a crisis or at immediate risk, contact the emergency line directly. This form notifies Wellbeing, but it may take a few minutes to be read.';

  @override
  String get sosEstudianteNuevaSolicitud => 'New request';

  @override
  String get sosEstudianteQueNecesitasBreve => 'What do you need? (brief)';

  @override
  String get sosEstudianteTelefonoDeContactoOpcional =>
      'Contact phone (optional)';

  @override
  String get sosEstudianteEnviarSolicitud => 'Send request';

  @override
  String get sosEstudianteMisSolicitudesAnteriores => 'My previous requests';

  @override
  String get sosEstudianteAunNoHasEnviado =>
      'You have not sent any requests yet.';

  @override
  String get usuariosAdminExportarAExcel => 'Export to Excel';

  @override
  String get usuariosAdminNuevaCuenta => 'New account';

  @override
  String get usuariosAdminNoHayUsuariosEn => 'No users with this filter.';

  @override
  String get usuariosAdminContrasenaMin8Caracteres =>
      'Password (min. 8 characters)';

  @override
  String get usuariosAdminRol => 'Role';

  @override
  String get usuariosAdminBienestar => 'Wellbeing';

  @override
  String get usuariosAdminAdmin => 'Admin';

  @override
  String get usuariosAdminGuardar => 'Save';

  @override
  String agendaBienestarDisponibilidadFecha(Object fecha) {
    return 'Availability - $fecha';
  }

  @override
  String agendaBienestarCitasFecha(Object fecha) {
    return 'Appointments - $fecha';
  }

  @override
  String get agendaBienestarHoraDeInicio => 'START TIME';

  @override
  String get agendaBienestarHoraDeFin => 'END TIME';

  @override
  String get filtroTodos => 'All';

  @override
  String get nivelSevero => 'Severe';

  @override
  String get nivelModSevero => 'Mod. severe';

  @override
  String get nivelModerado => 'Moderate';

  @override
  String get nivelLeve => 'Mild';

  @override
  String get nivelMinimo => 'Minimal';

  @override
  String get filtroPendientes => 'Pending';

  @override
  String get filtroConfirmadas => 'Confirmed';

  @override
  String get filtroReagendadas => 'Rescheduled';

  @override
  String get filtroAtendidas => 'Attended';

  @override
  String get filtroCanceladas => 'Cancelled';

  @override
  String get filtroTodas => 'All';

  @override
  String citasEstudianteHorariosDisponiblesFecha(Object fecha) {
    return 'Available times - $fecha';
  }

  @override
  String get citasEstudiantePorAsignar => 'To be assigned';

  @override
  String get citasEstudianteElProfesionalAsignado =>
      'the assigned professional';

  @override
  String get disponibilidadBienestarCompletaTodosLosCampos =>
      'Fill in the date, start time and end time.';

  @override
  String get disponibilidadBienestarElegirFecha => 'Pick a date';

  @override
  String get disponibilidadBienestarHoraInicio => 'Start time';

  @override
  String get disponibilidadBienestarHoraFin => 'End time';

  @override
  String get disponibilidadBienestarActiva => 'Active';

  @override
  String get disponibilidadBienestarDesactivada => 'Inactive';

  @override
  String get temaClaro => 'Light theme';

  @override
  String get temaOscuro => 'Dark theme';

  @override
  String get perfil => 'Profile';

  @override
  String get homeStaffSolicitudesPendientes => 'Pending requests';

  @override
  String get homeStaffCitasDeHoy => 'Today’s appointments';

  @override
  String get homeStaffCitasEstaSemana => 'Appointments this week';

  @override
  String get homeStaffEstudiantes => 'Students';

  @override
  String get homeStaffAdministradores => 'Administrators';

  @override
  String get inactivityGuardSesionCerradaInactividad =>
      'Your session was closed due to inactivity.';

  @override
  String get inactivityGuardSesionOtroDispositivo =>
      'Your session was closed because you signed in with this account on another device.';

  @override
  String get inactivityGuardNoSePudoVerificar =>
      'Could not verify the password.';

  @override
  String get registerSeleccionaTuProgramaAcademico =>
      'Select your academic program.';

  @override
  String get filtroEnProceso => 'In progress';

  @override
  String get sosEstudianteNoSePudoCargar => 'Could not load your history.';

  @override
  String get sosEstudianteCuentanosBrevemente =>
      'Tell us briefly what you need.';

  @override
  String get usuariosAdminEditarUsuario => 'Edit user';

  @override
  String get opcionNunca => 'Not at all';

  @override
  String get opcionVariosDias => 'Several days';

  @override
  String get opcionMasDeLaMitad => 'More than half the days';

  @override
  String get opcionCasiTodos => 'Nearly every day';

  @override
  String get nivelModeradamenteSevero => 'Moderately severe';

  @override
  String get phq9Pregunta1 => 'Little interest or pleasure in doing things';

  @override
  String get phq9Pregunta2 => 'Feeling down, depressed, or hopeless';

  @override
  String get phq9Pregunta3 =>
      'Trouble falling or staying asleep, or sleeping too much';

  @override
  String get phq9Pregunta4 => 'Feeling tired or having little energy';

  @override
  String get phq9Pregunta5 => 'Poor appetite or overeating';

  @override
  String get phq9Pregunta6 =>
      'Feeling bad about yourself, or that you are a failure or have let yourself or your family down';

  @override
  String get phq9Pregunta7 =>
      'Trouble concentrating on things, such as reading the newspaper or watching television';

  @override
  String get phq9Pregunta8 =>
      'Moving or speaking so slowly that other people could have noticed, or the opposite: being so fidgety or restless that you have been moving around a lot more than usual';

  @override
  String get phq9Pregunta9 =>
      'Thoughts that you would be better off dead, or of hurting yourself in some way';

  @override
  String citasEstudianteVasASolicitar(
    Object profesional,
    Object fecha,
    Object hora,
  ) {
    return 'You are about to request an appointment with $profesional\n$fecha at $hora.\n\nWellbeing will need to confirm it.';
  }

  @override
  String get estadoPendiente => 'Pending';

  @override
  String get estadoEnProceso => 'In progress';

  @override
  String get estadoConfirmada => 'Confirmed';

  @override
  String get estadoReagendada => 'Rescheduled';

  @override
  String get estadoAtendida => 'Attended';

  @override
  String get estadoCancelada => 'Cancelled';

  @override
  String get calendarioMes => 'Month';

  @override
  String get calendarioDosSemanas => '2 weeks';

  @override
  String get calendarioSemana => 'Week';

  @override
  String citaFecha(Object fecha) {
    return 'Date: $fecha';
  }

  @override
  String citaMotivo(Object motivo) {
    return 'Reason: $motivo';
  }

  @override
  String sosTelefono(Object telefono) {
    return 'Phone: $telefono';
  }

  @override
  String get politicaSeccion1Titulo => '1. Data controller';

  @override
  String get politicaSeccion1Texto =>
      'SEREO is a platform developed for the University Wellbeing area of Universidad de Cundinamarca, aimed at the psychological and emotional support of its student community. The University Wellbeing area acts as the controller of the personal data collected through this application.';

  @override
  String get politicaSeccion2Titulo => '2. Data collected';

  @override
  String get politicaSeccion2Texto =>
      '• Identification data: full name, institutional email, academic program.\n• Access credentials: password (stored in encrypted form).\n• Sensitive mental health data: priority care requests (SOS), emotional journal, psychological self-assessments, and history of appointments with Wellbeing professionals.\n• Technical data: application preferences and session data.';

  @override
  String get politicaSeccion3Titulo => '3. Purpose of the processing';

  @override
  String get politicaSeccion3Texto =>
      'To verify your identity and membership of the university community, manage psychological care requests and appointments, allow authorized professionals to follow up on your emotional wellbeing, and generate aggregated, anonymous statistics to support institutional decisions.';

  @override
  String get politicaSeccion4Titulo =>
      '4. Confidentiality of sensitive information';

  @override
  String get politicaSeccion4Texto =>
      'Information related to your emotional state (journal, self-assessments, SOS requests) is confidential. Only authorized Wellbeing staff have access, and only in the context necessary to provide you with care. The system’s administrative staff do NOT have access to this information under any circumstances.';

  @override
  String get politicaSeccion5Titulo => '5. Data retention';

  @override
  String get politicaSeccion5Texto =>
      'Information is not permanently deleted. Requests, appointments and accounts can be cancelled or deactivated, but they are kept for traceability, audit and continuity of support.';

  @override
  String get politicaSeccion6Titulo => '6. Your rights';

  @override
  String get politicaSeccion6Texto =>
      'You have the right to know, update and rectify your data; to be informed about how it is used; to file complaints with the competent authorities; and to revoke your authorization or request the deletion of your data, when there is no legal duty preventing it.';

  @override
  String get politicaSeccion7Titulo => '7. Use of local storage';

  @override
  String get politicaSeccion7Texto =>
      'SEREO uses local storage on your device (similar to cookies in web applications) to keep your session active and remember your preferences, such as the visual theme. This information remains only on your device.';

  @override
  String get politicaSeccion8Titulo => '8. Acceptance';

  @override
  String get politicaSeccion8Texto =>
      'Using SEREO requires express acceptance of this policy, in accordance with Law 1581 of 2012 and its implementing decrees.';

  @override
  String get passwordHintMin10 => 'At least 10 characters';

  @override
  String get passwordReqTitle => 'Your password must have:';

  @override
  String get passwordReqLength => 'At least 10 characters';

  @override
  String get passwordReqUpper => 'One uppercase letter';

  @override
  String get passwordReqLower => 'One lowercase letter';

  @override
  String get passwordReqNumber => 'One number';

  @override
  String get passwordReqSpecial =>
      'One special character (for example ! @ # %)';

  @override
  String get passwordPolicyError =>
      'The password does not meet the security requirements.';

  @override
  String get passwordErrPersonal =>
      'It cannot contain your name or part of your email.';

  @override
  String get passwordErrCommon => 'That password is too common.';

  @override
  String get perfilDatosBasicos => 'Basic information';

  @override
  String get perfilSemestre => 'Semester';

  @override
  String get perfilTelefono => 'Phone';

  @override
  String get perfilOpcional => '(optional)';

  @override
  String get perfilContactoEmergencia => 'Emergency contact';

  @override
  String get perfilContactoNombre => 'Contact name';

  @override
  String get perfilContactoTelefono => 'Contact phone';

  @override
  String get perfilGuardarCambios => 'Save changes';

  @override
  String get perfilGuardado => 'Profile updated';

  @override
  String get perfilSeguridad => 'Security';

  @override
  String get perfilCambiarContrasena => 'Change password';

  @override
  String get perfilContrasenaActual => 'Current password';

  @override
  String get perfilContrasenaNueva => 'New password';

  @override
  String get perfilConfirmarNueva => 'Confirm new password';

  @override
  String get perfilContrasenaCambiada => 'Password updated successfully';

  @override
  String perfilPoliticaAceptada(String fecha) {
    return 'Data policy accepted on $fecha';
  }

  @override
  String get perfilErrNombre => 'Enter your full name (at least 3 characters).';

  @override
  String get perfilErrPrograma => 'Select a valid academic program.';

  @override
  String get perfilErrSemestre => 'The semester must be between 1 and 12.';

  @override
  String get perfilErrTelefono =>
      'Enter a valid phone number (7 to 15 digits).';

  @override
  String get perfilErrContactoIncompleto =>
      'Fill in both the name and the phone of the emergency contact.';

  @override
  String get perfilErrContactoNombre => 'The contact name is not valid.';

  @override
  String get perfilErrContrasenaActual =>
      'The current password is not correct.';

  @override
  String get perfilErrNoCoinciden => 'The passwords do not match.';

  @override
  String get perfilErrIgualActual =>
      'The new password must be different from the current one.';

  @override
  String get perfilErrSesion =>
      'Your session is not valid. Please sign in again.';
}
