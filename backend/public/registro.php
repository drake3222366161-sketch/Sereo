<?php

require_once __DIR__ . '/../lib/audit.php';
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

$datos = json_decode(file_get_contents('php://input'), true);

$nombre = trim($datos['nombre_completo'] ?? '');
$correo = trim(strtolower($datos['correo'] ?? ''));
$contrasena = $datos['contrasena'] ?? '';
$confirmarContrasena = $datos['confirmar_contrasena'] ?? '';
$programa = trim($datos['programa_academico'] ?? '');

if (!$nombre || !$correo || !$contrasena || !$confirmarContrasena || !$programa) {
    http_response_code(400);
    echo json_encode(['error' => 'Todos los campos son obligatorios.']);
    exit;
}

if (!str_ends_with($correo, '@ucundinamarca.edu.co')) {
    http_response_code(403);
    echo json_encode(['error' => 'Debes registrarte con tu correo institucional (@ucundinamarca.edu.co).']);
    exit;
}

if ($contrasena !== $confirmarContrasena) {
    http_response_code(400);
    echo json_encode(['error' => 'Las contraseñas no coinciden.']);
    exit;
}

$fallos = validarPoliticaContrasena($contrasena, $correo, $nombre);
if ($fallos) {
    registrarLog($pdo, 'REGISTRO_FALLIDO', 'auth', null, ['motivo' => 'contrasena_no_cumple_politica', 'requisitos_fallidos' => $fallos], 'error', $correo);
    responderPoliticaContrasenaInvalida($fallos);
}

$stmt = $pdo->prepare('SELECT id FROM usuarios WHERE correo = :correo LIMIT 1');
$stmt->execute(['correo' => $correo]);
if ($stmt->fetch()) {
    registrarLog($pdo, 'REGISTRO_FALLIDO', 'auth', null, ['motivo' => 'correo_ya_registrado'], 'error', $correo);
    http_response_code(409);
    echo json_encode(['error' => 'Ya existe una cuenta registrada con ese correo.']);
    exit;
}

$hash = password_hash($contrasena, PASSWORD_DEFAULT);
$tokenSesion = bin2hex(random_bytes(16));

$stmt = $pdo->prepare(
    'INSERT INTO usuarios (nombre_completo, correo, contrasena_hash, rol, programa_academico, token_sesion)
     VALUES (:nombre, :correo, :hash, :rol, :programa, :token)'
);
$stmt->execute([
    'nombre' => $nombre,
    'correo' => $correo,
    'hash' => $hash,
    'rol' => 'estudiante',
    'programa' => $programa,
    'token' => $tokenSesion,
]);

$nuevoId = $pdo->lastInsertId();

registrarLog($pdo, 'REGISTRO_EXITOSO', 'auth', ['id' => (int) $nuevoId, 'correo' => $correo, 'rol' => 'estudiante']);

echo json_encode([
    'mensaje' => 'Cuenta creada correctamente',
    'usuario' => [
        'id' => $nuevoId,
        'nombre' => $nombre,
        'correo' => $correo,
        'rol' => 'estudiante',
        'programa_academico' => $programa,
        'politica_aceptada' => false,
        'token_sesion' => $tokenSesion,
    ]
]);

