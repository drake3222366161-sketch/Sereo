import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'SEREO'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get register;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @sos.
  ///
  /// In es, this message translates to:
  /// **'Ayuda SOS'**
  String get sos;

  /// No description provided for @appointments.
  ///
  /// In es, this message translates to:
  /// **'Citas'**
  String get appointments;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @welcomeUser.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido, {name}'**
  String welcomeUser(String name);

  /// No description provided for @err_invalid_credentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos'**
  String get err_invalid_credentials;

  /// No description provided for @appSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Acompañamiento psicológico universitario'**
  String get appSubtitle;

  /// No description provided for @institutionalEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo institucional'**
  String get institutionalEmail;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'usuario'**
  String get emailHint;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get noAccount;

  /// No description provided for @signUpLink.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get signUpLink;

  /// No description provided for @studentsOnlyNote.
  ///
  /// In es, this message translates to:
  /// **'Solo estudiantes pueden registrarse aquí. El personal de Bienestar y Administración recibe su cuenta directamente.'**
  String get studentsOnlyNote;

  /// No description provided for @err_captcha.
  ///
  /// In es, this message translates to:
  /// **'La verificación no es correcta. Intenta de nuevo.'**
  String get err_captcha;

  /// No description provided for @err_connection.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión: {detail}'**
  String err_connection(String detail);

  /// No description provided for @agendaBienestarDesactivarEstaFranja.
  ///
  /// In es, this message translates to:
  /// **'¿Desactivar esta franja?'**
  String get agendaBienestarDesactivarEstaFranja;

  /// No description provided for @agendaBienestarVasADesactivarLa.
  ///
  /// In es, this message translates to:
  /// **'Vas a desactivar la disponibilidad del {fecha} de {horaInicio} a {horaFin}.\n\nYa no aparecerá como opción para que los estudiantes agenden citas ahí, pero quedará registrada en el historial.'**
  String agendaBienestarVasADesactivarLa(
    Object fecha,
    Object horaInicio,
    Object horaFin,
  );

  /// No description provided for @agendaBienestarCancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get agendaBienestarCancelar;

  /// No description provided for @agendaBienestarSiDesactivar.
  ///
  /// In es, this message translates to:
  /// **'Sí, desactivar'**
  String get agendaBienestarSiDesactivar;

  /// No description provided for @agendaBienestarCancelarEstaCita.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar esta cita?'**
  String get agendaBienestarCancelarEstaCita;

  /// No description provided for @agendaBienestarVasACancelarLa.
  ///
  /// In es, this message translates to:
  /// **'Vas a cancelar la cita de {estudianteNombre} ({fechaHora}).'**
  String agendaBienestarVasACancelarLa(
    Object estudianteNombre,
    Object fechaHora,
  );

  /// No description provided for @agendaBienestarNoVolver.
  ///
  /// In es, this message translates to:
  /// **'No, volver'**
  String get agendaBienestarNoVolver;

  /// No description provided for @agendaBienestarSiCancelar.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get agendaBienestarSiCancelar;

  /// No description provided for @agendaBienestarAgregar.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get agendaBienestarAgregar;

  /// No description provided for @agendaBienestarNoHasDefinidoDisponibilidad.
  ///
  /// In es, this message translates to:
  /// **'No has definido disponibilidad este día.'**
  String get agendaBienestarNoHasDefinidoDisponibilidad;

  /// No description provided for @agendaBienestarDesactivar.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get agendaBienestarDesactivar;

  /// No description provided for @agendaBienestarNoTienesCitasEste.
  ///
  /// In es, this message translates to:
  /// **'No tienes citas este día.'**
  String get agendaBienestarNoTienesCitasEste;

  /// No description provided for @agendaBienestarConfirmar.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get agendaBienestarConfirmar;

  /// No description provided for @agendaBienestarMarcarAtendida.
  ///
  /// In es, this message translates to:
  /// **'Marcar atendida'**
  String get agendaBienestarMarcarAtendida;

  /// No description provided for @agendaBienestarReagendar.
  ///
  /// In es, this message translates to:
  /// **'Reagendar'**
  String get agendaBienestarReagendar;

  /// No description provided for @autoevaluacionEstudianteRespondeTodasLasPreguntas.
  ///
  /// In es, this message translates to:
  /// **'Responde todas las preguntas antes de continuar.'**
  String get autoevaluacionEstudianteRespondeTodasLasPreguntas;

  /// No description provided for @autoevaluacionEstudianteErrorDeConexion.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión: {e}'**
  String autoevaluacionEstudianteErrorDeConexion(Object e);

  /// No description provided for @autoevaluacionEstudianteResultadoDeTuAutoevaluacion.
  ///
  /// In es, this message translates to:
  /// **'Resultado de tu autoevaluación'**
  String get autoevaluacionEstudianteResultadoDeTuAutoevaluacion;

  /// No description provided for @autoevaluacionEstudiantePuntaje27.
  ///
  /// In es, this message translates to:
  /// **'Puntaje: {puntaje} / 27'**
  String autoevaluacionEstudiantePuntaje27(Object puntaje);

  /// No description provided for @autoevaluacionEstudianteNivel.
  ///
  /// In es, this message translates to:
  /// **'Nivel: {clasificacion}'**
  String autoevaluacionEstudianteNivel(Object clasificacion);

  /// No description provided for @autoevaluacionEstudianteUnaDeTusRespuestas.
  ///
  /// In es, this message translates to:
  /// **'Una de tus respuestas indica que podrías estar pasando por un momento difícil. No estás solo(a) - te recomendamos hablar con Bienestar Universitario lo antes posible, o usar el botón de Solicitud prioritaria (SOS) desde la pantalla principal.'**
  String get autoevaluacionEstudianteUnaDeTusRespuestas;

  /// No description provided for @autoevaluacionEstudianteEsteResultadoEsUn.
  ///
  /// In es, this message translates to:
  /// **'Este resultado es un tamizaje, no un diagnóstico. Si sientes que necesitas apoyo, Bienestar Universitario está disponible para ti.'**
  String get autoevaluacionEstudianteEsteResultadoEsUn;

  /// No description provided for @autoevaluacionEstudianteEntendido.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get autoevaluacionEstudianteEntendido;

  /// No description provided for @autoevaluacionEstudianteAutoevaluacion.
  ///
  /// In es, this message translates to:
  /// **'Autoevaluación'**
  String get autoevaluacionEstudianteAutoevaluacion;

  /// No description provided for @autoevaluacionEstudiantePhq9.
  ///
  /// In es, this message translates to:
  /// **'PHQ-9'**
  String get autoevaluacionEstudiantePhq9;

  /// No description provided for @autoevaluacionEstudianteTestBreveDeTamizaje.
  ///
  /// In es, this message translates to:
  /// **'Test breve de tamizaje, usado ampliamente en entornos clínicos para identificar señales de ánimo bajo en las últimas 2 semanas. Toma menos de 3 minutos.'**
  String get autoevaluacionEstudianteTestBreveDeTamizaje;

  /// No description provided for @autoevaluacionEstudianteComenzarAutoevaluacion.
  ///
  /// In es, this message translates to:
  /// **'Comenzar autoevaluación'**
  String get autoevaluacionEstudianteComenzarAutoevaluacion;

  /// No description provided for @autoevaluacionEstudianteMiHistorial.
  ///
  /// In es, this message translates to:
  /// **'Mi historial'**
  String get autoevaluacionEstudianteMiHistorial;

  /// No description provided for @autoevaluacionEstudianteAunNoHasRealizado.
  ///
  /// In es, this message translates to:
  /// **'Aún no has realizado ninguna autoevaluación.'**
  String get autoevaluacionEstudianteAunNoHasRealizado;

  /// No description provided for @autoevaluacionEstudianteDuranteLasUltimas2.
  ///
  /// In es, this message translates to:
  /// **'Durante las últimas 2 semanas, ¿con qué frecuencia te ha molestado cada uno de los siguientes problemas?'**
  String get autoevaluacionEstudianteDuranteLasUltimas2;

  /// No description provided for @autoevaluacionEstudianteEnviarRespuestas.
  ///
  /// In es, this message translates to:
  /// **'Enviar respuestas'**
  String get autoevaluacionEstudianteEnviarRespuestas;

  /// No description provided for @autoevaluacionesBienestarNoHayResultadosEn.
  ///
  /// In es, this message translates to:
  /// **'No hay resultados en este filtro.'**
  String get autoevaluacionesBienestarNoHayResultadosEn;

  /// No description provided for @backupRestoreAdminNoSePudoGenerar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar el backup.'**
  String get backupRestoreAdminNoSePudoGenerar;

  /// No description provided for @backupRestoreAdminRestaurarBaseDeDatos.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Restaurar base de datos'**
  String get backupRestoreAdminRestaurarBaseDeDatos;

  /// No description provided for @backupRestoreAdminVasARestaurarDesde.
  ///
  /// In es, this message translates to:
  /// **'Vas a restaurar desde el archivo \"{nombreArchivo}\".\n\nEsto BORRA todos los datos actuales (usuarios, citas, SOS, autoevaluaciones, todo) y los reemplaza por los del backup. Esta acción no se puede deshacer.'**
  String backupRestoreAdminVasARestaurarDesde(Object nombreArchivo);

  /// No description provided for @backupRestoreAdminEntiendoContinuar.
  ///
  /// In es, this message translates to:
  /// **'Entiendo, continuar'**
  String get backupRestoreAdminEntiendoContinuar;

  /// No description provided for @backupRestoreAdminConfirmacionFinal.
  ///
  /// In es, this message translates to:
  /// **'Confirmación final'**
  String get backupRestoreAdminConfirmacionFinal;

  /// No description provided for @backupRestoreAdminEscribeRestaurarEnMayusculas.
  ///
  /// In es, this message translates to:
  /// **'Escribe RESTAURAR (en mayúsculas) para confirmar:'**
  String get backupRestoreAdminEscribeRestaurarEnMayusculas;

  /// No description provided for @backupRestoreAdminRestaurarAhora.
  ///
  /// In es, this message translates to:
  /// **'Restaurar ahora'**
  String get backupRestoreAdminRestaurarAhora;

  /// No description provided for @backupRestoreAdminBaseDeDatosRestaurada.
  ///
  /// In es, this message translates to:
  /// **'Base de datos restaurada correctamente.'**
  String get backupRestoreAdminBaseDeDatosRestaurada;

  /// No description provided for @backupRestoreAdminGenerarBackup.
  ///
  /// In es, this message translates to:
  /// **'Generar backup'**
  String get backupRestoreAdminGenerarBackup;

  /// No description provided for @backupRestoreAdminDescargaUnArchivoSql.
  ///
  /// In es, this message translates to:
  /// **'Descarga un archivo .sql con toda la información actual.'**
  String get backupRestoreAdminDescargaUnArchivoSql;

  /// No description provided for @backupRestoreAdminRestaurarBackup.
  ///
  /// In es, this message translates to:
  /// **'Restaurar backup'**
  String get backupRestoreAdminRestaurarBackup;

  /// No description provided for @backupRestoreAdminReemplazaTodosLosDatos.
  ///
  /// In es, this message translates to:
  /// **'Reemplaza TODOS los datos actuales por los de un archivo .sql.'**
  String get backupRestoreAdminReemplazaTodosLosDatos;

  /// No description provided for @backupRestoreAdminRecomendacionGeneraUnBackup.
  ///
  /// In es, this message translates to:
  /// **'Recomendación: genera un backup regularmente (por ejemplo, antes de cada entrega), y guárdalo en un lugar seguro fuera del computador (correo, USB, nube).'**
  String get backupRestoreAdminRecomendacionGeneraUnBackup;

  /// No description provided for @captchaWidgetOtraOperacion.
  ///
  /// In es, this message translates to:
  /// **'Otra operación'**
  String get captchaWidgetOtraOperacion;

  /// No description provided for @citasBienestarNoHayCitasEn.
  ///
  /// In es, this message translates to:
  /// **'No hay citas en este filtro.'**
  String get citasBienestarNoHayCitasEn;

  /// No description provided for @citasEstudianteConfirmarCita.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cita'**
  String get citasEstudianteConfirmarCita;

  /// No description provided for @citasEstudianteSolicitar.
  ///
  /// In es, this message translates to:
  /// **'Solicitar'**
  String get citasEstudianteSolicitar;

  /// No description provided for @citasEstudianteVasACancelarTu.
  ///
  /// In es, this message translates to:
  /// **'Vas a cancelar tu cita con {profesional} ({fechaHora}).'**
  String citasEstudianteVasACancelarTu(Object profesional, Object fechaHora);

  /// No description provided for @citasEstudianteAgendarCita.
  ///
  /// In es, this message translates to:
  /// **'Agendar cita'**
  String get citasEstudianteAgendarCita;

  /// No description provided for @citasEstudianteNoHayHorariosLibres.
  ///
  /// In es, this message translates to:
  /// **'No hay horarios libres este día.'**
  String get citasEstudianteNoHayHorariosLibres;

  /// No description provided for @citasEstudianteMisCitas.
  ///
  /// In es, this message translates to:
  /// **'Mis citas'**
  String get citasEstudianteMisCitas;

  /// No description provided for @citasEstudianteAunNoTienesCitas.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes citas agendadas.'**
  String get citasEstudianteAunNoTienesCitas;

  /// No description provided for @disponibilidadBienestarAgregarFranjaDeDisponibilidad.
  ///
  /// In es, this message translates to:
  /// **'Agregar franja de disponibilidad'**
  String get disponibilidadBienestarAgregarFranjaDeDisponibilidad;

  /// No description provided for @disponibilidadBienestarMisFranjas.
  ///
  /// In es, this message translates to:
  /// **'Mis franjas'**
  String get disponibilidadBienestarMisFranjas;

  /// No description provided for @disponibilidadBienestarAunNoHasAgregado.
  ///
  /// In es, this message translates to:
  /// **'Aún no has agregado disponibilidad.'**
  String get disponibilidadBienestarAunNoHasAgregado;

  /// No description provided for @homeEstudianteModuloEnConstruccion.
  ///
  /// In es, this message translates to:
  /// **'{modulo} — módulo en construcción'**
  String homeEstudianteModuloEnConstruccion(Object modulo);

  /// No description provided for @homeEstudianteHola.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombreEstudiante}'**
  String homeEstudianteHola(Object nombreEstudiante);

  /// No description provided for @homeEstudianteCerrarSesion.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get homeEstudianteCerrarSesion;

  /// No description provided for @homeEstudianteSolicitudPrioritariaSos.
  ///
  /// In es, this message translates to:
  /// **'Solicitud prioritaria (SOS)'**
  String get homeEstudianteSolicitudPrioritariaSos;

  /// No description provided for @homeEstudianteSiNecesitasAyudaUrgente.
  ///
  /// In es, this message translates to:
  /// **'Si necesitas ayuda urgente'**
  String get homeEstudianteSiNecesitasAyudaUrgente;

  /// No description provided for @homeEstudianteDiarioEmocional.
  ///
  /// In es, this message translates to:
  /// **'Diario emocional'**
  String get homeEstudianteDiarioEmocional;

  /// No description provided for @homeEstudianteMiPerfil.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get homeEstudianteMiPerfil;

  /// No description provided for @homeStaffDashboard.
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get homeStaffDashboard;

  /// No description provided for @homeStaffUsuarios.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get homeStaffUsuarios;

  /// No description provided for @homeStaffConfiguracion.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get homeStaffConfiguracion;

  /// No description provided for @homeStaffSolicitudes.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes'**
  String get homeStaffSolicitudes;

  /// No description provided for @homeStaffAutoevaluaciones.
  ///
  /// In es, this message translates to:
  /// **'Autoevaluaciones'**
  String get homeStaffAutoevaluaciones;

  /// No description provided for @homeStaffAgenda.
  ///
  /// In es, this message translates to:
  /// **'Agenda'**
  String get homeStaffAgenda;

  /// No description provided for @homeStaffReportes.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get homeStaffReportes;

  /// No description provided for @homeStaffActualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get homeStaffActualizar;

  /// No description provided for @homeStaffEsteModuloEstaEn.
  ///
  /// In es, this message translates to:
  /// **'Este módulo está en construcción'**
  String get homeStaffEsteModuloEstaEn;

  /// No description provided for @inactivityGuardSesionBloqueadaPorInactividad.
  ///
  /// In es, this message translates to:
  /// **'Sesión bloqueada por inactividad'**
  String get inactivityGuardSesionBloqueadaPorInactividad;

  /// No description provided for @inactivityGuardDesbloquear.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear'**
  String get inactivityGuardDesbloquear;

  /// No description provided for @politicaPoliticaDeTratamientoDe.
  ///
  /// In es, this message translates to:
  /// **'Política de tratamiento de datos'**
  String get politicaPoliticaDeTratamientoDe;

  /// No description provided for @politicaPoliticaDeTratamientoDe2.
  ///
  /// In es, this message translates to:
  /// **'POLÍTICA DE TRATAMIENTO DE DATOS PERSONALES — SEREO'**
  String get politicaPoliticaDeTratamientoDe2;

  /// No description provided for @politicaHeLeidoYAcepto.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto la política de tratamiento de datos personales.'**
  String get politicaHeLeidoYAcepto;

  /// No description provided for @politicaAceptarYContinuar.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get politicaAceptarYContinuar;

  /// No description provided for @registerCrearCuentaDeEstudiante.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta de estudiante'**
  String get registerCrearCuentaDeEstudiante;

  /// No description provided for @registerRegistrateConTuCorreo.
  ///
  /// In es, this message translates to:
  /// **'Regístrate con tu correo institucional'**
  String get registerRegistrateConTuCorreo;

  /// No description provided for @registerNombreCompleto.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get registerNombreCompleto;

  /// No description provided for @registerAnaMariaGomez.
  ///
  /// In es, this message translates to:
  /// **'Ana María Gómez'**
  String get registerAnaMariaGomez;

  /// No description provided for @registerProgramaAcademico.
  ///
  /// In es, this message translates to:
  /// **'Programa académico'**
  String get registerProgramaAcademico;

  /// No description provided for @registerSeleccionaTuPrograma.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu programa'**
  String get registerSeleccionaTuPrograma;

  /// No description provided for @registerAdministracionDeEmpresas.
  ///
  /// In es, this message translates to:
  /// **'Administración de Empresas'**
  String get registerAdministracionDeEmpresas;

  /// No description provided for @registerContaduriaPublica.
  ///
  /// In es, this message translates to:
  /// **'Contaduría Pública'**
  String get registerContaduriaPublica;

  /// No description provided for @registerZootecnia.
  ///
  /// In es, this message translates to:
  /// **'Zootecnia'**
  String get registerZootecnia;

  /// No description provided for @registerIngenieriaDeSistemasY.
  ///
  /// In es, this message translates to:
  /// **'Ingeniería de Sistemas y Computación'**
  String get registerIngenieriaDeSistemasY;

  /// No description provided for @registerIngenieriaElectronica.
  ///
  /// In es, this message translates to:
  /// **'Ingeniería Electrónica'**
  String get registerIngenieriaElectronica;

  /// No description provided for @registerCienciasSociales.
  ///
  /// In es, this message translates to:
  /// **'Ciencias Sociales'**
  String get registerCienciasSociales;

  /// No description provided for @registerEducacionFisica.
  ///
  /// In es, this message translates to:
  /// **'Educación Física'**
  String get registerEducacionFisica;

  /// No description provided for @registerMinimo8Caracteres.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get registerMinimo8Caracteres;

  /// No description provided for @registerConfirmarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get registerConfirmarContrasena;

  /// No description provided for @registerRepiteTuContrasena.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get registerRepiteTuContrasena;

  /// No description provided for @registerCrearCuenta.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get registerCrearCuenta;

  /// No description provided for @reportesBienestarNoSePudoAbrir.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir el reporte. Verifica tu conexión.'**
  String get reportesBienestarNoSePudoAbrir;

  /// No description provided for @reportesBienestarExportarAExcelCsv.
  ///
  /// In es, this message translates to:
  /// **'Exportar a Excel (CSV)'**
  String get reportesBienestarExportarAExcelCsv;

  /// No description provided for @reportesBienestarSeDescargaUnArchivo.
  ///
  /// In es, this message translates to:
  /// **'Se descarga un archivo que abre directamente en Excel, listo para filtrar y analizar.'**
  String get reportesBienestarSeDescargaUnArchivo;

  /// No description provided for @reportesBienestarEstadisticasPorProgramaAcademico.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas por programa académico'**
  String get reportesBienestarEstadisticasPorProgramaAcademico;

  /// No description provided for @reportesBienestarSosCitasYAutoevaluaciones.
  ///
  /// In es, this message translates to:
  /// **'SOS, citas y autoevaluaciones agrupadas por carrera — el reporte más útil para identificar dónde hay mayor necesidad de acompañamiento.'**
  String get reportesBienestarSosCitasYAutoevaluaciones;

  /// No description provided for @reportesBienestarHistorialDeSolicitudesSos.
  ///
  /// In es, this message translates to:
  /// **'Historial de solicitudes SOS'**
  String get reportesBienestarHistorialDeSolicitudesSos;

  /// No description provided for @reportesBienestarListadoCompletoConEstudiante.
  ///
  /// In es, this message translates to:
  /// **'Listado completo con estudiante, estado y fechas.'**
  String get reportesBienestarListadoCompletoConEstudiante;

  /// No description provided for @reportesBienestarHistorialDeCitas.
  ///
  /// In es, this message translates to:
  /// **'Historial de citas'**
  String get reportesBienestarHistorialDeCitas;

  /// No description provided for @reportesBienestarTodasLasCitasAgendadas.
  ///
  /// In es, this message translates to:
  /// **'Todas las citas agendadas, con su estado y profesional asignado.'**
  String get reportesBienestarTodasLasCitasAgendadas;

  /// No description provided for @reportesBienestarResumenEjecutivoPdf.
  ///
  /// In es, this message translates to:
  /// **'Resumen ejecutivo (PDF)'**
  String get reportesBienestarResumenEjecutivoPdf;

  /// No description provided for @reportesBienestarSeAbreUnaPagina.
  ///
  /// In es, this message translates to:
  /// **'Se abre una página lista para imprimir o guardar como PDF (Ctrl+P), ideal para presentar en una reunión.'**
  String get reportesBienestarSeAbreUnaPagina;

  /// No description provided for @reportesBienestarResumenEjecutivoDeIndicadores.
  ///
  /// In es, this message translates to:
  /// **'Resumen ejecutivo de indicadores'**
  String get reportesBienestarResumenEjecutivoDeIndicadores;

  /// No description provided for @reportesBienestarUnVistazoGeneralTotales.
  ///
  /// In es, this message translates to:
  /// **'Un vistazo general: totales, SOS pendientes, y promedio del PHQ-9 por programa.'**
  String get reportesBienestarUnVistazoGeneralTotales;

  /// No description provided for @sosBienestarNoHaySolicitudesEn.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes en este filtro.'**
  String get sosBienestarNoHaySolicitudesEn;

  /// No description provided for @sosBienestarTomarCaso.
  ///
  /// In es, this message translates to:
  /// **'Tomar caso'**
  String get sosBienestarTomarCaso;

  /// No description provided for @sosEstudianteSolicitudEnviadaBienestarLa.
  ///
  /// In es, this message translates to:
  /// **'Solicitud enviada. Bienestar la atenderá pronto.'**
  String get sosEstudianteSolicitudEnviadaBienestarLa;

  /// No description provided for @sosEstudianteSiEstasEnUna.
  ///
  /// In es, this message translates to:
  /// **'Si estás en una situación de crisis o riesgo inmediato, comunícate directamente con la línea de emergencias. Este formulario notifica a Bienestar, pero puede tardar unos minutos en ser leído.'**
  String get sosEstudianteSiEstasEnUna;

  /// No description provided for @sosEstudianteNuevaSolicitud.
  ///
  /// In es, this message translates to:
  /// **'Nueva solicitud'**
  String get sosEstudianteNuevaSolicitud;

  /// No description provided for @sosEstudianteQueNecesitasBreve.
  ///
  /// In es, this message translates to:
  /// **'¿Qué necesitas? (breve)'**
  String get sosEstudianteQueNecesitasBreve;

  /// No description provided for @sosEstudianteTelefonoDeContactoOpcional.
  ///
  /// In es, this message translates to:
  /// **'Teléfono de contacto (opcional)'**
  String get sosEstudianteTelefonoDeContactoOpcional;

  /// No description provided for @sosEstudianteEnviarSolicitud.
  ///
  /// In es, this message translates to:
  /// **'Enviar solicitud'**
  String get sosEstudianteEnviarSolicitud;

  /// No description provided for @sosEstudianteMisSolicitudesAnteriores.
  ///
  /// In es, this message translates to:
  /// **'Mis solicitudes anteriores'**
  String get sosEstudianteMisSolicitudesAnteriores;

  /// No description provided for @sosEstudianteAunNoHasEnviado.
  ///
  /// In es, this message translates to:
  /// **'Aún no has enviado ninguna solicitud.'**
  String get sosEstudianteAunNoHasEnviado;

  /// No description provided for @usuariosAdminExportarAExcel.
  ///
  /// In es, this message translates to:
  /// **'Exportar a Excel'**
  String get usuariosAdminExportarAExcel;

  /// No description provided for @usuariosAdminNuevaCuenta.
  ///
  /// In es, this message translates to:
  /// **'Nueva cuenta'**
  String get usuariosAdminNuevaCuenta;

  /// No description provided for @usuariosAdminNoHayUsuariosEn.
  ///
  /// In es, this message translates to:
  /// **'No hay usuarios en este filtro.'**
  String get usuariosAdminNoHayUsuariosEn;

  /// No description provided for @usuariosAdminContrasenaMin8Caracteres.
  ///
  /// In es, this message translates to:
  /// **'Contraseña (mín. 8 caracteres)'**
  String get usuariosAdminContrasenaMin8Caracteres;

  /// No description provided for @usuariosAdminRol.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get usuariosAdminRol;

  /// No description provided for @usuariosAdminBienestar.
  ///
  /// In es, this message translates to:
  /// **'Bienestar'**
  String get usuariosAdminBienestar;

  /// No description provided for @usuariosAdminAdmin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get usuariosAdminAdmin;

  /// No description provided for @usuariosAdminGuardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get usuariosAdminGuardar;

  /// No description provided for @agendaBienestarDisponibilidadFecha.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad - {fecha}'**
  String agendaBienestarDisponibilidadFecha(Object fecha);

  /// No description provided for @agendaBienestarCitasFecha.
  ///
  /// In es, this message translates to:
  /// **'Citas - {fecha}'**
  String agendaBienestarCitasFecha(Object fecha);

  /// No description provided for @agendaBienestarHoraDeInicio.
  ///
  /// In es, this message translates to:
  /// **'HORA DE INICIO'**
  String get agendaBienestarHoraDeInicio;

  /// No description provided for @agendaBienestarHoraDeFin.
  ///
  /// In es, this message translates to:
  /// **'HORA DE FIN'**
  String get agendaBienestarHoraDeFin;

  /// No description provided for @filtroTodos.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filtroTodos;

  /// No description provided for @nivelSevero.
  ///
  /// In es, this message translates to:
  /// **'Severo'**
  String get nivelSevero;

  /// No description provided for @nivelModSevero.
  ///
  /// In es, this message translates to:
  /// **'Mod. severo'**
  String get nivelModSevero;

  /// No description provided for @nivelModerado.
  ///
  /// In es, this message translates to:
  /// **'Moderado'**
  String get nivelModerado;

  /// No description provided for @nivelLeve.
  ///
  /// In es, this message translates to:
  /// **'Leve'**
  String get nivelLeve;

  /// No description provided for @nivelMinimo.
  ///
  /// In es, this message translates to:
  /// **'Mínimo'**
  String get nivelMinimo;

  /// No description provided for @filtroPendientes.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get filtroPendientes;

  /// No description provided for @filtroConfirmadas.
  ///
  /// In es, this message translates to:
  /// **'Confirmadas'**
  String get filtroConfirmadas;

  /// No description provided for @filtroReagendadas.
  ///
  /// In es, this message translates to:
  /// **'Reagendadas'**
  String get filtroReagendadas;

  /// No description provided for @filtroAtendidas.
  ///
  /// In es, this message translates to:
  /// **'Atendidas'**
  String get filtroAtendidas;

  /// No description provided for @filtroCanceladas.
  ///
  /// In es, this message translates to:
  /// **'Canceladas'**
  String get filtroCanceladas;

  /// No description provided for @filtroTodas.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get filtroTodas;

  /// No description provided for @citasEstudianteHorariosDisponiblesFecha.
  ///
  /// In es, this message translates to:
  /// **'Horarios disponibles - {fecha}'**
  String citasEstudianteHorariosDisponiblesFecha(Object fecha);

  /// No description provided for @citasEstudiantePorAsignar.
  ///
  /// In es, this message translates to:
  /// **'Por asignar'**
  String get citasEstudiantePorAsignar;

  /// No description provided for @citasEstudianteElProfesionalAsignado.
  ///
  /// In es, this message translates to:
  /// **'el profesional asignado'**
  String get citasEstudianteElProfesionalAsignado;

  /// No description provided for @disponibilidadBienestarCompletaTodosLosCampos.
  ///
  /// In es, this message translates to:
  /// **'Completa fecha, hora inicio y hora fin.'**
  String get disponibilidadBienestarCompletaTodosLosCampos;

  /// No description provided for @disponibilidadBienestarElegirFecha.
  ///
  /// In es, this message translates to:
  /// **'Elegir fecha'**
  String get disponibilidadBienestarElegirFecha;

  /// No description provided for @disponibilidadBienestarHoraInicio.
  ///
  /// In es, this message translates to:
  /// **'Hora inicio'**
  String get disponibilidadBienestarHoraInicio;

  /// No description provided for @disponibilidadBienestarHoraFin.
  ///
  /// In es, this message translates to:
  /// **'Hora fin'**
  String get disponibilidadBienestarHoraFin;

  /// No description provided for @disponibilidadBienestarActiva.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get disponibilidadBienestarActiva;

  /// No description provided for @disponibilidadBienestarDesactivada.
  ///
  /// In es, this message translates to:
  /// **'Desactivada'**
  String get disponibilidadBienestarDesactivada;

  /// No description provided for @temaClaro.
  ///
  /// In es, this message translates to:
  /// **'Tema claro'**
  String get temaClaro;

  /// No description provided for @temaOscuro.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro'**
  String get temaOscuro;

  /// No description provided for @perfil.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get perfil;

  /// No description provided for @homeStaffSolicitudesPendientes.
  ///
  /// In es, this message translates to:
  /// **'Solicitudes pendientes'**
  String get homeStaffSolicitudesPendientes;

  /// No description provided for @homeStaffCitasDeHoy.
  ///
  /// In es, this message translates to:
  /// **'Citas de hoy'**
  String get homeStaffCitasDeHoy;

  /// No description provided for @homeStaffCitasEstaSemana.
  ///
  /// In es, this message translates to:
  /// **'Citas esta semana'**
  String get homeStaffCitasEstaSemana;

  /// No description provided for @homeStaffEstudiantes.
  ///
  /// In es, this message translates to:
  /// **'Estudiantes'**
  String get homeStaffEstudiantes;

  /// No description provided for @homeStaffAdministradores.
  ///
  /// In es, this message translates to:
  /// **'Administradores'**
  String get homeStaffAdministradores;

  /// No description provided for @inactivityGuardSesionCerradaInactividad.
  ///
  /// In es, this message translates to:
  /// **'Se cerró tu sesión por inactividad.'**
  String get inactivityGuardSesionCerradaInactividad;

  /// No description provided for @inactivityGuardSesionOtroDispositivo.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión fue cerrada porque iniciaste sesión con esta cuenta en otro dispositivo.'**
  String get inactivityGuardSesionOtroDispositivo;

  /// No description provided for @inactivityGuardNoSePudoVerificar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar la contraseña.'**
  String get inactivityGuardNoSePudoVerificar;

  /// No description provided for @registerSeleccionaTuProgramaAcademico.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu programa académico.'**
  String get registerSeleccionaTuProgramaAcademico;

  /// No description provided for @filtroEnProceso.
  ///
  /// In es, this message translates to:
  /// **'En proceso'**
  String get filtroEnProceso;

  /// No description provided for @sosEstudianteNoSePudoCargar.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar tu historial.'**
  String get sosEstudianteNoSePudoCargar;

  /// No description provided for @sosEstudianteCuentanosBrevemente.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos brevemente qué necesitas.'**
  String get sosEstudianteCuentanosBrevemente;

  /// No description provided for @usuariosAdminEditarUsuario.
  ///
  /// In es, this message translates to:
  /// **'Editar usuario'**
  String get usuariosAdminEditarUsuario;

  /// No description provided for @opcionNunca.
  ///
  /// In es, this message translates to:
  /// **'Nunca'**
  String get opcionNunca;

  /// No description provided for @opcionVariosDias.
  ///
  /// In es, this message translates to:
  /// **'Varios días'**
  String get opcionVariosDias;

  /// No description provided for @opcionMasDeLaMitad.
  ///
  /// In es, this message translates to:
  /// **'Más de la mitad de los días'**
  String get opcionMasDeLaMitad;

  /// No description provided for @opcionCasiTodos.
  ///
  /// In es, this message translates to:
  /// **'Casi todos los días'**
  String get opcionCasiTodos;

  /// No description provided for @nivelModeradamenteSevero.
  ///
  /// In es, this message translates to:
  /// **'Moderadamente severo'**
  String get nivelModeradamenteSevero;

  /// No description provided for @phq9Pregunta1.
  ///
  /// In es, this message translates to:
  /// **'Poco interés o placer en hacer las cosas'**
  String get phq9Pregunta1;

  /// No description provided for @phq9Pregunta2.
  ///
  /// In es, this message translates to:
  /// **'Sentirse desanimado(a), deprimido(a) o sin esperanza'**
  String get phq9Pregunta2;

  /// No description provided for @phq9Pregunta3.
  ///
  /// In es, this message translates to:
  /// **'Dificultad para dormir o permanecer dormido(a), o dormir demasiado'**
  String get phq9Pregunta3;

  /// No description provided for @phq9Pregunta4.
  ///
  /// In es, this message translates to:
  /// **'Sentirse cansado(a) o tener poca energía'**
  String get phq9Pregunta4;

  /// No description provided for @phq9Pregunta5.
  ///
  /// In es, this message translates to:
  /// **'Poco apetito o comer en exceso'**
  String get phq9Pregunta5;

  /// No description provided for @phq9Pregunta6.
  ///
  /// In es, this message translates to:
  /// **'Sentirse mal consigo mismo(a), o sentir que es un fracaso o que ha quedado mal con usted mismo(a) o con su familia'**
  String get phq9Pregunta6;

  /// No description provided for @phq9Pregunta7.
  ///
  /// In es, this message translates to:
  /// **'Dificultad para concentrarse en cosas como leer el periódico o ver televisión'**
  String get phq9Pregunta7;

  /// No description provided for @phq9Pregunta8.
  ///
  /// In es, this message translates to:
  /// **'Moverse o hablar tan lentamente que otras personas podrían notarlo, o lo contrario: estar tan inquieto(a) o agitado(a) que se ha estado moviendo mucho más de lo normal'**
  String get phq9Pregunta8;

  /// No description provided for @phq9Pregunta9.
  ///
  /// In es, this message translates to:
  /// **'Pensamientos de que estaría mejor muerto(a) o de hacerse daño de alguna manera'**
  String get phq9Pregunta9;

  /// No description provided for @citasEstudianteVasASolicitar.
  ///
  /// In es, this message translates to:
  /// **'Vas a solicitar una cita con {profesional}\n{fecha} a las {hora}.\n\nBienestar deberá confirmarla.'**
  String citasEstudianteVasASolicitar(
    Object profesional,
    Object fecha,
    Object hora,
  );

  /// No description provided for @estadoPendiente.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get estadoPendiente;

  /// No description provided for @estadoEnProceso.
  ///
  /// In es, this message translates to:
  /// **'En proceso'**
  String get estadoEnProceso;

  /// No description provided for @estadoConfirmada.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get estadoConfirmada;

  /// No description provided for @estadoReagendada.
  ///
  /// In es, this message translates to:
  /// **'Reagendada'**
  String get estadoReagendada;

  /// No description provided for @estadoAtendida.
  ///
  /// In es, this message translates to:
  /// **'Atendida'**
  String get estadoAtendida;

  /// No description provided for @estadoCancelada.
  ///
  /// In es, this message translates to:
  /// **'Cancelada'**
  String get estadoCancelada;

  /// No description provided for @calendarioMes.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get calendarioMes;

  /// No description provided for @calendarioDosSemanas.
  ///
  /// In es, this message translates to:
  /// **'2 semanas'**
  String get calendarioDosSemanas;

  /// No description provided for @calendarioSemana.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get calendarioSemana;

  /// No description provided for @citaFecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha: {fecha}'**
  String citaFecha(Object fecha);

  /// No description provided for @citaMotivo.
  ///
  /// In es, this message translates to:
  /// **'Motivo: {motivo}'**
  String citaMotivo(Object motivo);

  /// No description provided for @sosTelefono.
  ///
  /// In es, this message translates to:
  /// **'Tel: {telefono}'**
  String sosTelefono(Object telefono);

  /// No description provided for @politicaSeccion1Titulo.
  ///
  /// In es, this message translates to:
  /// **'1. Responsable del tratamiento'**
  String get politicaSeccion1Titulo;

  /// No description provided for @politicaSeccion1Texto.
  ///
  /// In es, this message translates to:
  /// **'SEREO es una plataforma desarrollada para el área de Bienestar Universitario de la Universidad de Cundinamarca, orientada al acompañamiento psicológico y emocional de su comunidad estudiantil. El área de Bienestar Universitario actúa como responsable del tratamiento de los datos personales recolectados a través de esta aplicación.'**
  String get politicaSeccion1Texto;

  /// No description provided for @politicaSeccion2Titulo.
  ///
  /// In es, this message translates to:
  /// **'2. Datos que se recolectan'**
  String get politicaSeccion2Titulo;

  /// No description provided for @politicaSeccion2Texto.
  ///
  /// In es, this message translates to:
  /// **'• Datos de identificación: nombre completo, correo institucional, programa académico.\n• Credenciales de acceso: contraseña (almacenada de forma cifrada).\n• Datos sensibles de salud mental: solicitudes de atención prioritaria (SOS), diario emocional, autoevaluaciones psicológicas, e historial de citas con profesionales de Bienestar.\n• Datos técnicos: preferencias de la aplicación y datos de sesión.'**
  String get politicaSeccion2Texto;

  /// No description provided for @politicaSeccion3Titulo.
  ///
  /// In es, this message translates to:
  /// **'3. Finalidad del tratamiento'**
  String get politicaSeccion3Titulo;

  /// No description provided for @politicaSeccion3Texto.
  ///
  /// In es, this message translates to:
  /// **'Verificar tu identidad y pertenencia a la comunidad universitaria, gestionar solicitudes de atención psicológica y citas, permitir el seguimiento de tu bienestar emocional por parte de profesionales autorizados, y generar estadísticas agregadas y anónimas para apoyar decisiones institucionales.'**
  String get politicaSeccion3Texto;

  /// No description provided for @politicaSeccion4Titulo.
  ///
  /// In es, this message translates to:
  /// **'4. Confidencialidad de la información sensible'**
  String get politicaSeccion4Titulo;

  /// No description provided for @politicaSeccion4Texto.
  ///
  /// In es, this message translates to:
  /// **'La información relacionada con tu estado emocional (diario, autoevaluaciones, solicitudes SOS) es confidencial. Solo el personal de Bienestar autorizado tiene acceso, y únicamente en el contexto necesario para brindarte atención. El personal administrativo del sistema NO tiene acceso a esta información bajo ninguna circunstancia.'**
  String get politicaSeccion4Texto;

  /// No description provided for @politicaSeccion5Titulo.
  ///
  /// In es, this message translates to:
  /// **'5. Conservación de la información'**
  String get politicaSeccion5Titulo;

  /// No description provided for @politicaSeccion5Texto.
  ///
  /// In es, this message translates to:
  /// **'La información no se elimina de forma permanente. Las solicitudes, citas y cuentas pueden cancelarse o desactivarse, pero se conservan con fines de trazabilidad, auditoría y continuidad del acompañamiento.'**
  String get politicaSeccion5Texto;

  /// No description provided for @politicaSeccion6Titulo.
  ///
  /// In es, this message translates to:
  /// **'6. Tus derechos'**
  String get politicaSeccion6Titulo;

  /// No description provided for @politicaSeccion6Texto.
  ///
  /// In es, this message translates to:
  /// **'Tienes derecho a conocer, actualizar y rectificar tus datos; ser informado sobre su uso; presentar quejas ante las autoridades competentes; y revocar tu autorización o solicitar la supresión de tus datos, cuando no exista un deber legal que lo impida.'**
  String get politicaSeccion6Texto;

  /// No description provided for @politicaSeccion7Titulo.
  ///
  /// In es, this message translates to:
  /// **'7. Uso de almacenamiento local'**
  String get politicaSeccion7Titulo;

  /// No description provided for @politicaSeccion7Texto.
  ///
  /// In es, this message translates to:
  /// **'SEREO utiliza almacenamiento local en tu dispositivo (similar a las cookies en aplicaciones web) para mantener tu sesión activa y recordar tus preferencias, como el tema visual. Esta información permanece únicamente en tu dispositivo.'**
  String get politicaSeccion7Texto;

  /// No description provided for @politicaSeccion8Titulo.
  ///
  /// In es, this message translates to:
  /// **'8. Aceptación'**
  String get politicaSeccion8Titulo;

  /// No description provided for @politicaSeccion8Texto.
  ///
  /// In es, this message translates to:
  /// **'El uso de SEREO requiere la aceptación expresa de esta política, de acuerdo con la Ley 1581 de 2012 y sus decretos reglamentarios.'**
  String get politicaSeccion8Texto;

  /// No description provided for @passwordHintMin10.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 10 caracteres'**
  String get passwordHintMin10;

  /// No description provided for @passwordReqTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu contraseña debe tener:'**
  String get passwordReqTitle;

  /// No description provided for @passwordReqLength.
  ///
  /// In es, this message translates to:
  /// **'Al menos 10 caracteres'**
  String get passwordReqLength;

  /// No description provided for @passwordReqUpper.
  ///
  /// In es, this message translates to:
  /// **'Una letra mayúscula'**
  String get passwordReqUpper;

  /// No description provided for @passwordReqLower.
  ///
  /// In es, this message translates to:
  /// **'Una letra minúscula'**
  String get passwordReqLower;

  /// No description provided for @passwordReqNumber.
  ///
  /// In es, this message translates to:
  /// **'Un número'**
  String get passwordReqNumber;

  /// No description provided for @passwordReqSpecial.
  ///
  /// In es, this message translates to:
  /// **'Un carácter especial (por ejemplo ! @ # %)'**
  String get passwordReqSpecial;

  /// No description provided for @passwordPolicyError.
  ///
  /// In es, this message translates to:
  /// **'La contraseña no cumple los requisitos de seguridad.'**
  String get passwordPolicyError;

  /// No description provided for @passwordErrPersonal.
  ///
  /// In es, this message translates to:
  /// **'No puede contener tu nombre ni parte de tu correo.'**
  String get passwordErrPersonal;

  /// No description provided for @passwordErrCommon.
  ///
  /// In es, this message translates to:
  /// **'Es una contraseña demasiado común.'**
  String get passwordErrCommon;

  /// No description provided for @perfilDatosBasicos.
  ///
  /// In es, this message translates to:
  /// **'Datos básicos'**
  String get perfilDatosBasicos;

  /// No description provided for @perfilSemestre.
  ///
  /// In es, this message translates to:
  /// **'Semestre'**
  String get perfilSemestre;

  /// No description provided for @perfilTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get perfilTelefono;

  /// No description provided for @perfilOpcional.
  ///
  /// In es, this message translates to:
  /// **'(opcional)'**
  String get perfilOpcional;

  /// No description provided for @perfilContactoEmergencia.
  ///
  /// In es, this message translates to:
  /// **'Contacto de emergencia'**
  String get perfilContactoEmergencia;

  /// No description provided for @perfilContactoNombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre del contacto'**
  String get perfilContactoNombre;

  /// No description provided for @perfilContactoTelefono.
  ///
  /// In es, this message translates to:
  /// **'Teléfono del contacto'**
  String get perfilContactoTelefono;

  /// No description provided for @perfilGuardarCambios.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get perfilGuardarCambios;

  /// No description provided for @perfilGuardado.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado'**
  String get perfilGuardado;

  /// No description provided for @perfilSeguridad.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get perfilSeguridad;

  /// No description provided for @perfilCambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get perfilCambiarContrasena;

  /// No description provided for @perfilContrasenaActual.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get perfilContrasenaActual;

  /// No description provided for @perfilContrasenaNueva.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get perfilContrasenaNueva;

  /// No description provided for @perfilConfirmarNueva.
  ///
  /// In es, this message translates to:
  /// **'Confirmar nueva contraseña'**
  String get perfilConfirmarNueva;

  /// No description provided for @perfilContrasenaCambiada.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada correctamente'**
  String get perfilContrasenaCambiada;

  /// No description provided for @perfilPoliticaAceptada.
  ///
  /// In es, this message translates to:
  /// **'Política de datos aceptada el {fecha}'**
  String perfilPoliticaAceptada(String fecha);

  /// No description provided for @perfilErrNombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre completo (mínimo 3 caracteres).'**
  String get perfilErrNombre;

  /// No description provided for @perfilErrPrograma.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un programa académico válido.'**
  String get perfilErrPrograma;

  /// No description provided for @perfilErrSemestre.
  ///
  /// In es, this message translates to:
  /// **'El semestre debe estar entre 1 y 12.'**
  String get perfilErrSemestre;

  /// No description provided for @perfilErrTelefono.
  ///
  /// In es, this message translates to:
  /// **'Escribe un teléfono válido (de 7 a 15 dígitos).'**
  String get perfilErrTelefono;

  /// No description provided for @perfilErrContactoIncompleto.
  ///
  /// In es, this message translates to:
  /// **'Completa el nombre y el teléfono del contacto de emergencia.'**
  String get perfilErrContactoIncompleto;

  /// No description provided for @perfilErrContactoNombre.
  ///
  /// In es, this message translates to:
  /// **'El nombre del contacto no es válido.'**
  String get perfilErrContactoNombre;

  /// No description provided for @perfilErrContrasenaActual.
  ///
  /// In es, this message translates to:
  /// **'La contraseña actual no es correcta.'**
  String get perfilErrContrasenaActual;

  /// No description provided for @perfilErrNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get perfilErrNoCoinciden;

  /// No description provided for @perfilErrIgualActual.
  ///
  /// In es, this message translates to:
  /// **'La nueva contraseña debe ser distinta de la actual.'**
  String get perfilErrIgualActual;

  /// No description provided for @perfilErrSesion.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión no es válida. Vuelve a iniciar sesión.'**
  String get perfilErrSesion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
