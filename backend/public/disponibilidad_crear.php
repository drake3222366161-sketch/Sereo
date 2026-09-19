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

$profesionalId = $datos['profesional_id'] ?? null;
$fecha = $datos['fecha'] ?? null;         // formato 'YYYY-MM-DD'
$horaInicio = $datos['hora_inicio'] ?? null; // formato 'HH:MM'
$horaFin = $datos['hora_fin'] ?? null;

if (!$profesionalId || !$fecha || !$horaInicio || !$horaFin) {
    http_response_code(400);
    echo json_encode(['error' => 'Todos los campos son obligatorios.']);
    exit;
}

if ($horaFin <= $horaInicio) {
    http_response_code(400);
    echo json_encode(['error' => 'La hora de fin debe ser después de la hora de inicio.']);
    exit;
}

// No dejar crear una franja en el pasado
if ($fecha < date('Y-m-d')) {
    http_response_code(400);
    echo json_encode(['error' => 'No puedes crear disponibilidad en una fecha pasada.']);
    exit;
}

$stmt = $pdo->prepare(
    'INSERT INTO disponibilidad_profesional (profesional_id, fecha, hora_inicio, hora_fin)
     VALUES (:profesional_id, :fecha, :hora_inicio, :hora_fin)'
);
$stmt->execute([
    'profesional_id' => $profesionalId,
    'fecha' => $fecha,
    'hora_inicio' => $horaInicio,
    'hora_fin' => $horaFin,
]);

echo json_encode(['mensaje' => 'Disponibilidad agregada.', 'id' => $pdo->lastInsertId()]);
