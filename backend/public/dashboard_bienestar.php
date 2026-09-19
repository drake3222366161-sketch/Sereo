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

// 1. Solicitudes SOS pendientes (de todos, cualquier bienestar puede tomarlas)
$stmt = $pdo->query("SELECT COUNT(*) AS total FROM solicitudes_sos WHERE estado = 'pendiente'");
$sosPendientes = (int) $stmt->fetch()['total'];

// 2. Citas de hoy (confirmadas o pendientes, sin contar las canceladas)
$stmt = $pdo->query(
    "SELECT COUNT(*) AS total FROM citas
     WHERE DATE(fecha_hora) = CURDATE()
       AND estado NOT IN ('cancelada')"
);
$citasHoy = (int) $stmt->fetch()['total'];

// 3. Citas confirmadas de toda esta semana (dato extra, útil para el dashboard)
$stmt = $pdo->query(
    "SELECT COUNT(*) AS total FROM citas
     WHERE YEARWEEK(fecha_hora, 1) = YEARWEEK(CURDATE(), 1)
       AND estado NOT IN ('cancelada')"
);
$citasSemana = (int) $stmt->fetch()['total'];

echo json_encode([
    'sos_pendientes' => $sosPendientes,
    'citas_hoy' => $citasHoy,
    'citas_semana' => $citasSemana,
]);
