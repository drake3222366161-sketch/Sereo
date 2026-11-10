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

$estudianteId = $datos['estudiante_id'] ?? null;
$nota = trim($datos['nota'] ?? '');
$telefono = trim($datos['telefono_contacto'] ?? '');

if (!$estudianteId || !$nota) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos obligatorios (nota).']);
    exit;
}

$stmt = $pdo->prepare(
    'INSERT INTO solicitudes_sos (estudiante_id, nota, telefono_contacto)
     VALUES (:estudiante_id, :nota, :telefono)'
);
$stmt->execute([
    'estudiante_id' => $estudianteId,
    'nota' => $nota,
    'telefono' => $telefono ?: null,
]);

$solicitudId = $pdo->lastInsertId();
// Solo el hecho: la nota y el teléfono son datos sensibles y NO van al log
registrarLog($pdo, 'SOS_CREADO', 'sos', $estudianteId, ['solicitud_id' => (int) $solicitudId]);

echo json_encode([
    'mensaje' => 'Solicitud enviada. Bienestar la atenderá pronto.',
    'solicitud_id' => $solicitudId,
]);

