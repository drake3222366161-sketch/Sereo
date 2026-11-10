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
$rol = $datos['rol'] ?? '';
$adminId = $datos['admin_id'] ?? null; // quién crea la cuenta (para el log)

if (!$nombre || !$correo || !$contrasena || !$rol) {
    http_response_code(400);
    echo json_encode(['error' => 'Todos los campos son obligatorios.']);
    exit;
}

// El admin SOLO puede crear cuentas de bienestar o admin.
// Los estudiantes se autoregistran, nunca se crean desde aquí.
if (!in_array($rol, ['bienestar', 'admin'])) {
    registrarLog($pdo, 'USUARIO_CREACION_DENEGADA', 'usuarios', $adminId, ['rol_solicitado' => $rol], 'denegado');
    http_response_code(403);
    echo json_encode(['error' => 'Desde aquí solo se pueden crear cuentas de Bienestar o Admin.']);
    exit;
}

if (!str_ends_with($correo, '@ucundinamarca.edu.co')) {
    http_response_code(403);
    echo json_encode(['error' => 'El correo debe ser institucional (@ucundinamarca.edu.co).']);
    exit;
}

$fallos = validarPoliticaContrasena($contrasena, $correo, $nombre);
if ($fallos) {
    registrarLog($pdo, 'USUARIO_CREACION_DENEGADA', 'usuarios', $adminId, ['motivo' => 'contrasena_no_cumple_politica', 'requisitos_fallidos' => $fallos], 'denegado');
    responderPoliticaContrasenaInvalida($fallos);
}

$stmt = $pdo->prepare('SELECT id FROM usuarios WHERE correo = :correo LIMIT 1');
$stmt->execute(['correo' => $correo]);
if ($stmt->fetch()) {
    http_response_code(409);
    echo json_encode(['error' => 'Ya existe una cuenta con ese correo.']);
    exit;
}

$hash = password_hash($contrasena, PASSWORD_DEFAULT);

$stmt = $pdo->prepare(
    'INSERT INTO usuarios (nombre_completo, correo, contrasena_hash, rol)
     VALUES (:nombre, :correo, :hash, :rol)'
);
$stmt->execute([
    'nombre' => $nombre,
    'correo' => $correo,
    'hash' => $hash,
    'rol' => $rol,
]);

$nuevoId = $pdo->lastInsertId();
registrarLog($pdo, 'USUARIO_CREADO', 'usuarios', $adminId, ['usuario_creado_id' => (int) $nuevoId, 'correo' => $correo, 'rol' => $rol]);

echo json_encode(['mensaje' => 'Cuenta creada correctamente.', 'id' => $nuevoId]);

