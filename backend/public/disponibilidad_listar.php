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
$modo = $datos['modo'] ?? '';

if ($modo === 'propias') {
    // Bienestar ve TODAS sus franjas (pasadas y futuras), para poder gestionarlas
    $profesionalId = $datos['profesional_id'] ?? null;
    if (!$profesionalId) {
        http_response_code(400);
        echo json_encode(['error' => 'Falta profesional_id.']);
        exit;
    }

    $stmt = $pdo->prepare(
        'SELECT id, fecha, hora_inicio, hora_fin, disponible
         FROM disponibilidad_profesional
         WHERE profesional_id = :id
         ORDER BY fecha ASC, hora_inicio ASC'
    );
    $stmt->execute(['id' => $profesionalId]);
    $franjas = $stmt->fetchAll(PDO::FETCH_ASSOC);

} elseif ($modo === 'libres') {
    // El estudiante ve solo franjas futuras, marcadas disponibles,
    // y que NO tengan ya una cita activa encima
    $stmt = $pdo->prepare(
        "SELECT d.id, d.fecha, d.hora_inicio, d.hora_fin,
                u.id AS profesional_id, u.nombre_completo AS profesional_nombre
         FROM disponibilidad_profesional d
         JOIN usuarios u ON u.id = d.profesional_id
         WHERE d.disponible = 1
           AND d.fecha >= CURDATE()
           AND NOT EXISTS (
               SELECT 1 FROM citas c
               WHERE c.profesional_id = d.profesional_id
                 AND c.fecha_hora = TIMESTAMP(d.fecha, d.hora_inicio)
                 AND c.estado NOT IN ('cancelada')
           )
         ORDER BY d.fecha ASC, d.hora_inicio ASC"
    );
    $stmt->execute();
    $franjas = $stmt->fetchAll(PDO::FETCH_ASSOC);

} else {
    http_response_code(400);
    echo json_encode(['error' => 'Modo no reconocido.']);
    exit;
}

echo json_encode(['franjas' => $franjas]);
