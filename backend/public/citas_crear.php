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

$estudianteId = $datos['estudiante_id'] ?? null;
$profesionalId = $datos['profesional_id'] ?? null;
$fecha = $datos['fecha'] ?? null;
$hora = $datos['hora'] ?? null;
$motivo = trim($datos['motivo'] ?? '');

if (!$estudianteId || !$profesionalId || !$fecha || !$hora) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos para agendar la cita.']);
    exit;
}

// 1. Verificar que esa franja SIGA libre (por si alguien más la tomó primero)
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS total FROM citas
     WHERE profesional_id = :profesional_id
       AND fecha_hora = TIMESTAMP(:fecha, :hora)
       AND estado NOT IN ('cancelada')"
);
$stmt->execute(['profesional_id' => $profesionalId, 'fecha' => $fecha, 'hora' => $hora]);
$ocupada = (int) $stmt->fetch()['total'] > 0;

if ($ocupada) {
    http_response_code(409);
    echo json_encode(['error' => 'Ese horario ya fue tomado por otro estudiante. Elige otro.']);
    exit;
}

// 2. Crear la cita en estado 'pendiente' (Bienestar la confirma después)
$stmt = $pdo->prepare(
    'INSERT INTO citas (estudiante_id, profesional_id, fecha_hora, motivo, estado)
     VALUES (:estudiante_id, :profesional_id, TIMESTAMP(:fecha, :hora), :motivo, :estado)'
);
$stmt->execute([
    'estudiante_id' => $estudianteId,
    'profesional_id' => $profesionalId,
    'fecha' => $fecha,
    'hora' => $hora,
    'motivo' => $motivo ?: null,
    'estado' => 'pendiente',
]);

echo json_encode([
    'mensaje' => 'Cita solicitada. Bienestar la confirmará pronto.',
    'cita_id' => $pdo->lastInsertId(),
]);
