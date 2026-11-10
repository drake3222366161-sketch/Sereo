<?php

require_once __DIR__ . '/../lib/audit.php';
require_once __DIR__ . '/../lib/auth.php';
require_once __DIR__ . '/../lib/password_policy.php';

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

function responderErrorContrasena(string $codigo, string $mensaje): void
{
    http_response_code(400);
    echo json_encode(['error' => $mensaje, 'codigo' => $codigo], JSON_UNESCAPED_UNICODE);
    exit;
}

$datos = json_decode(file_get_contents('php://input'), true) ?? [];

// Cualquier rol con sesión vigente puede cambiar SU propia contraseña.
$u = requerirSesion($pdo, $datos['usuario_id'] ?? null, $datos['token_sesion'] ?? null);

$actual = is_string($datos['contrasena_actual'] ?? null) ? $datos['contrasena_actual'] : '';
$nueva = is_string($datos['contrasena_nueva'] ?? null) ? $datos['contrasena_nueva'] : '';
$confirmar = is_string($datos['confirmar_contrasena'] ?? null) ? $datos['confirmar_contrasena'] : '';

if ($actual === '' || $nueva === '' || $confirmar === '') {
    responderErrorContrasena('campos_obligatorios', 'Todos los campos son obligatorios.');
}

if ($nueva !== $confirmar) {
    responderErrorContrasena('no_coinciden', 'Las contraseñas no coinciden.');
}

$st = $pdo->prepare('SELECT contrasena_hash FROM usuarios WHERE id = :id LIMIT 1');
$st->execute(['id' => $u['id']]);
$hashActual = (string) $st->fetchColumn();

if (!password_verify($actual, $hashActual)) {
    registrarLog($pdo, 'CAMBIO_CONTRASENA_FALLIDO', 'auth', $u, ['motivo' => 'contrasena_actual_incorrecta'], 'error');
    responderErrorContrasena('contrasena_actual_incorrecta', 'La contraseña actual no es correcta.');
}

$fallos = validarPoliticaContrasena($nueva, $u['correo'], $u['nombre_completo']);
if ($fallos) {
    registrarLog($pdo, 'CAMBIO_CONTRASENA_FALLIDO', 'auth', $u, ['motivo' => 'no_cumple_politica', 'requisitos_fallidos' => $fallos], 'error');
    responderPoliticaContrasenaInvalida($fallos);
}

if (hash_equals($actual, $nueva)) {
    responderErrorContrasena('igual_a_la_actual', 'La nueva contraseña debe ser distinta de la actual.');
}

// La sesión actual se mantiene (el token no cambia): quien cambia su contraseña sigue dentro.
$st = $pdo->prepare('UPDATE usuarios SET contrasena_hash = :h WHERE id = :id');
$st->execute(['h' => password_hash($nueva, PASSWORD_DEFAULT), 'id' => $u['id']]);

registrarLog($pdo, 'CONTRASENA_CAMBIADA', 'auth', $u);

echo json_encode(['mensaje' => 'Contraseña actualizada correctamente.'], JSON_UNESCAPED_UNICODE);
