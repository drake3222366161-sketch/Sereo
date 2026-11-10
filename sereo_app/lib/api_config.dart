/// Configuración central de la API.
///
/// Cuando quieras probar la app en tu celular (en vez de en tu PC), solo
/// tienes que cambiar esta URL por la IP local de tu computador, por
/// ejemplo: 'http://192.168.1.15/sereo/backend/public'
/// (la consigues con el comando `ipconfig` en la terminal de Windows).
///
/// Todas las pantallas de la app llaman a esta única constante, así que
/// el cambio se aplica automáticamente en todos lados.
class ApiConfig {
  static const String baseUrl = 'http://localhost/sereo/backend/public';
}
