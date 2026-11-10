<?php

require_once __DIR__ . '/../lib/audit.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$host = 'localhost';
$db   = 'sereodb';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'No se pudo conectar a la base de datos']);
    exit;
}

$datosRecibidos = json_decode(file_get_contents('php://input'), true);
$correo = trim(strtolower($datosRecibidos['correo'] ?? ''));
$contrasena = $datosRecibidos['contrasena'] ?? '';

if (!$correo || !$contrasena) {
    http_response_code(400);
    echo json_encode(['error' => 'Correo y contraseña son obligatorios']);
    exit;
}

if (!str_ends_with($correo, '@ucundinamarca.edu.co')) {
    registrarLog($pdo, 'LOGIN_FALLIDO', 'auth', null, ['motivo' => 'correo_no_institucional'], 'denegado', $correo);
    http_response_code(403);
    echo json_encode(['error' => 'Debes usar tu correo institucional (@ucundinamarca.edu.co).']);
    exit;
}

$stmt = $pdo->prepare('SELECT * FROM usuarios WHERE correo = :correo LIMIT 1');
$stmt->execute(['correo' => $correo]);
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    registrarLog($pdo, 'LOGIN_FALLIDO', 'auth', null, ['motivo' => 'correo_no_registrado'], 'error', $correo);
    http_response_code(401);
    echo json_encode(['error' => 'Ese correo no está registrado en SEREO.']);
    exit;
}

if (!$usuario['activo']) {
    registrarLog($pdo, 'LOGIN_FALLIDO', 'auth', $usuario, ['motivo' => 'cuenta_desactivada'], 'denegado');
    http_response_code(403);
    echo json_encode(['error' => 'Esta cuenta está desactivada. Contacta a Bienestar Universitario.']);
    exit;
}

if (!password_verify($contrasena, $usuario['contrasena_hash'])) {
    registrarLog($pdo, !empty($datosRecibidos['solo_verificar']) ? 'DESBLOQUEO_FALLIDO' : 'LOGIN_FALLIDO', 'auth', $usuario, ['motivo' => 'contrasena_incorrecta'], 'error');
    http_response_code(401);
    echo json_encode(['error' => 'La contraseña es incorrecta.']);
    exit;
}

// Desbloqueo de pantalla por inactividad: la app solo quiere comprobar la contraseña.
// NO se crea una sesión nueva (si se creara, el token guardado en el celular quedaría
// viejo y verificar_sesion.php cerraría la sesión por "otro dispositivo").
if (!empty($datosRecibidos['solo_verificar'])) {
    registrarLog($pdo, 'DESBLOQUEO_PANTALLA', 'auth', $usuario);
    echo json_encode(['mensaje' => 'Contraseña verificada.']);
    exit;
}

// Generamos un token nuevo y lo guardamos como "la sesión activa" de esta
// cuenta. Esto automáticamente invalida cualquier sesión anterior: si ya
// había una sesión abierta en otro dispositivo, su token viejo deja de
// coincidir con el que ahora hay en la base de datos, y esa otra sesión
// será cerrada la próxima vez que verifique si sigue siendo válida.
$tokenSesion = bin2hex(random_bytes(16));

$stmt = $pdo->prepare('UPDATE usuarios SET token_sesion = :token WHERE id = :id');
$stmt->execute(['token' => $tokenSesion, 'id' => $usuario['id']]);

// Auditoría: si ya había una sesión abierta, este login la reemplaza (una sola sesión por usuario)
if (!empty($usuario['token_sesion'])) {
    registrarLog($pdo, 'SESION_ANTERIOR_REEMPLAZADA', 'auth', $usuario, ['motivo' => 'nuevo_inicio_de_sesion']);
}
registrarLog($pdo, 'LOGIN_EXITOSO', 'auth', $usuario);

echo json_encode([
    'mensaje' => 'Login correcto',
    'usuario' => [
        'id' => $usuario['id'],
        'nombre' => $usuario['nombre_completo'],
        'correo' => $usuario['correo'],
        'rol' => $usuario['rol'],
        'programa_academico' => $usuario['programa_academico'],
        'politica_aceptada' => (bool) $usuario['politica_aceptada'],
        'token_sesion' => $tokenSesion,
    ]
]);

