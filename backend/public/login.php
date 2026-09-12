<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 1. Conexión a la base de datos
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

// 2. Leer los datos enviados por Flutter
$datosRecibidos = json_decode(file_get_contents('php://input'), true);
$correo = trim(strtolower($datosRecibidos['correo'] ?? ''));
$contrasena = $datosRecibidos['contrasena'] ?? '';

if (!$correo || !$contrasena) {
    http_response_code(400);
    echo json_encode(['error' => 'Correo y contraseña son obligatorios']);
    exit;
}

// 3. Validar dominio institucional
if (!str_ends_with($correo, '@ucundinamarca.edu.co')) {
    http_response_code(403);
    echo json_encode(['error' => 'Debes usar tu correo institucional (@ucundinamarca.edu.co).']);
    exit;
}

// 4. Buscar el usuario
$stmt = $pdo->prepare('SELECT * FROM usuarios WHERE correo = :correo LIMIT 1');
$stmt->execute(['correo' => $correo]);
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

// 5. Alertas específicas (a pedido del profesor)
//    NOTA DE SEGURIDAD: esto revela si un correo existe o no en el sistema.
//    Es una decisión consciente para esta entrega, no un descuido.
if (!$usuario) {
    http_response_code(401);
    echo json_encode(['error' => 'Ese correo no está registrado en SEREO.']);
    exit;
}

if (!$usuario['activo']) {
    http_response_code(403);
    echo json_encode(['error' => 'Esta cuenta está desactivada. Contacta a Bienestar Universitario.']);
    exit;
}

if (!password_verify($contrasena, $usuario['contrasena_hash'])) {
    http_response_code(401);
    echo json_encode(['error' => 'La contraseña es incorrecta.']);
    exit;
}

// 6. Todo bien
echo json_encode([
    'mensaje' => 'Login correcto',
    'usuario' => [
        'id' => $usuario['id'],
        'nombre' => $usuario['nombre_completo'],
        'correo' => $usuario['correo'],
        'rol' => $usuario['rol'],
        'programa_academico' => $usuario['programa_academico'],
    ]
]);