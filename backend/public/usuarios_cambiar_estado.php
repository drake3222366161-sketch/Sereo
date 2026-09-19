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
$nuevoEstado = $datos['activo'] ?? null; // true / false
$adminId = $datos['admin_id'] ?? null;

if ($id === null || $nuevoEstado === null || !$adminId) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos.']);
    exit;
}

// Un admin no puede desactivarse a sí mismo (evita que se quede sin acceso)
if ((int) $id === (int) $adminId && !$nuevoEstado) {
    http_response_code(403);
    echo json_encode(['error' => 'No puedes desactivar tu propia cuenta.']);
    exit;
}

$stmt = $pdo->prepare('UPDATE usuarios SET activo = :activo WHERE id = :id');
$stmt->execute(['activo' => $nuevoEstado ? 1 : 0, 'id' => $id]);

echo json_encode(['mensaje' => $nuevoEstado ? 'Cuenta activada.' : 'Cuenta desactivada.']);
