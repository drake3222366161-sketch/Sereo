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

// Eventos que SOLO la app puede saber (pasan en el dispositivo, no en el servidor).
// Lista cerrada: cualquier otro nombre se rechaza para que nadie llene la tabla de basura.
$permitidos = [
    'bloqueo_inactividad'    => 'BLOQUEO_PANTALLA_INACTIVIDAD',
    'desbloqueo_inactividad' => 'DESBLOQUEO_PANTALLA',
];

$datos = json_decode(file_get_contents('php://input'), true) ?? [];
$usuarioId = $datos['usuario_id'] ?? null;
$evento = $datos['evento'] ?? '';

if (!$usuarioId || !isset($permitidos[$evento])) {
    http_response_code(400);
    echo json_encode(['error' => 'Datos inválidos.']);
    exit;
}

// dedup de 20 s por si la app avisa dos veces seguidas
registrarLog($pdo, $permitidos[$evento], 'auth', $usuarioId, [], 'ok', null, 20);

echo json_encode(['mensaje' => 'Evento registrado.']);
