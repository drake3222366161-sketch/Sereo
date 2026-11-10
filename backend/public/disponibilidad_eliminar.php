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
$id = $datos['id'] ?? null;
$profesionalId = $datos['profesional_id'] ?? null;

if (!$id || !$profesionalId) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos.']);
    exit;
}

$stmt = $pdo->prepare('SELECT * FROM disponibilidad_profesional WHERE id = :id LIMIT 1');
$stmt->execute(['id' => $id]);
$franja = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$franja) {
    http_response_code(404);
    echo json_encode(['error' => 'La franja no existe.']);
    exit;
}

if ((int) $franja['profesional_id'] !== (int) $profesionalId) {
    registrarLog($pdo, 'DISPONIBILIDAD_ACCION_DENEGADA', 'disponibilidad', $profesionalId, ['franja_id' => (int) $id], 'denegado');
    http_response_code(403);
    echo json_encode(['error' => 'No puedes desactivar disponibilidad de otro profesional.']);
    exit;
}

// Verificar que no tenga ya una cita reservada encima
$stmt = $pdo->prepare(
    "SELECT COUNT(*) AS total FROM citas
     WHERE profesional_id = :profesional_id
       AND fecha_hora = TIMESTAMP(:fecha, :hora)
       AND estado NOT IN ('cancelada')"
);
$stmt->execute([
    'profesional_id' => $profesionalId,
    'fecha' => $franja['fecha'],
    'hora' => $franja['hora_inicio'],
]);
$tieneReserva = (int) $stmt->fetch()['total'] > 0;

if ($tieneReserva) {
    http_response_code(409);
    echo json_encode(['error' => 'Esta franja ya tiene una cita reservada, no se puede desactivar.']);
    exit;
}

// IMPORTANTE: en vez de DELETE, solo marcamos disponible = 0.
// La fila permanece en la base de datos para conservar el historial completo
// (así lo pidió el profesor: nunca se borra información, solo se desactiva).
$stmt = $pdo->prepare('UPDATE disponibilidad_profesional SET disponible = 0 WHERE id = :id');
$stmt->execute(['id' => $id]);

registrarLog($pdo, 'DISPONIBILIDAD_DESACTIVADA', 'disponibilidad', $profesionalId, ['id' => (int) $id, 'fecha' => $franja['fecha'], 'hora_inicio' => $franja['hora_inicio'], 'hora_fin' => $franja['hora_fin']]);

echo json_encode(['mensaje' => 'Franja desactivada.']);

