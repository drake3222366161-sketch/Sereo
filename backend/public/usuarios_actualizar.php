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

$id = $datos['id'] ?? null;
$nombre = trim($datos['nombre_completo'] ?? '');
$correo = trim(strtolower($datos['correo'] ?? ''));

if (!$id || !$nombre || !$correo) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos obligatorios.']);
    exit;
}

if (!str_ends_with($correo, '@ucundinamarca.edu.co')) {
    http_response_code(403);
    echo json_encode(['error' => 'El correo debe ser institucional.']);
    exit;
}

// Verificar que el correo no esté siendo usado por OTRO usuario
$stmt = $pdo->prepare('SELECT id FROM usuarios WHERE correo = :correo AND id != :id LIMIT 1');
$stmt->execute(['correo' => $correo, 'id' => $id]);
if ($stmt->fetch()) {
    http_response_code(409);
    echo json_encode(['error' => 'Ese correo ya lo usa otra cuenta.']);
    exit;
}

$stmt = $pdo->prepare(
    'UPDATE usuarios SET nombre_completo = :nombre, correo = :correo WHERE id = :id'
);
$stmt->execute(['nombre' => $nombre, 'correo' => $correo, 'id' => $id]);

echo json_encode(['mensaje' => 'Usuario actualizado.']);
