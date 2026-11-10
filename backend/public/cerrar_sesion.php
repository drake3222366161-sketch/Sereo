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

$datos = json_decode(file_get_contents('php://input'), true);
$usuarioId = $datos['usuario_id'] ?? null;

if (!$usuarioId) {
    http_response_code(400);
    echo json_encode(['error' => 'Falta usuario_id.']);
    exit;
}

$stmt = $pdo->prepare('UPDATE usuarios SET token_sesion = NULL WHERE id = :id');
$stmt->execute(['id' => $usuarioId]);

// El cliente puede enviar 'motivo' => 'inactividad' cuando la app cierra sola la sesión
$motivo = $datos['motivo'] ?? 'manual';
$accionLog = $motivo === 'inactividad' ? 'SESION_CERRADA_POR_INACTIVIDAD' : 'LOGOUT';
registrarLog($pdo, $accionLog, 'auth', $usuarioId);

echo json_encode(['mensaje' => 'Sesión cerrada.']);

