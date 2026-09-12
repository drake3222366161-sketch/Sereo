<?php

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

// 1. Campos obligatorios
if (!$nombre || !$correo || !$contrasena || !$confirmarContrasena || !$programa) {
    http_response_code(400);
    echo json_encode(['error' => 'Todos los campos son obligatorios.']);
    exit;
}

// 2. Dominio institucional
if (!str_ends_with($correo, '@ucundinamarca.edu.co')) {
    http_response_code(403);
    echo json_encode(['error' => 'Debes registrarte con tu correo institucional (@ucundinamarca.edu.co).']);
    exit;
}

// 3. Confirmación de contraseña
if ($contrasena !== $confirmarContrasena) {
    http_response_code(400);
    echo json_encode(['error' => 'Las contraseñas no coinciden.']);
    exit;
}

// 4. Contraseña mínima (regla simple, se puede endurecer después)
if (strlen($contrasena) < 8) {
    http_response_code(400);
    echo json_encode(['error' => 'La contraseña debe tener al menos 8 caracteres.']);
    exit;
}

// 5. Verificar que el correo no exista ya
$stmt = $pdo->prepare('SELECT id FROM usuarios WHERE correo = :correo LIMIT 1');
$stmt->execute(['correo' => $correo]);
if ($stmt->fetch()) {
    http_response_code(409); // 409 = Conflicto, el recurso ya existe
    echo json_encode(['error' => 'Ya existe una cuenta registrada con ese correo.']);
    exit;
}

// 6. Crear la cuenta (siempre con rol 'estudiante' - los otros roles los crea el Admin)
$hash = password_hash($contrasena, PASSWORD_DEFAULT);

$stmt = $pdo->prepare(
    'INSERT INTO usuarios (nombre_completo, correo, contrasena_hash, rol, programa_academico)
     VALUES (:nombre, :correo, :hash, :rol, :programa)'
);
$stmt->execute([
    'nombre' => $nombre,
    'correo' => $correo,
    'hash' => $hash,
    'rol' => 'estudiante',
    'programa' => $programa,
]);

$nuevoId = $pdo->lastInsertId();

echo json_encode([
    'mensaje' => 'Cuenta creada correctamente',
    'usuario' => [
        'id' => $nuevoId,
        'nombre' => $nombre,
        'correo' => $correo,
        'rol' => 'estudiante',
        'programa_academico' => $programa,
    ]
]);