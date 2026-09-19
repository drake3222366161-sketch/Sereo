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
$rol = $datos['rol'] ?? '';

if ($rol === 'estudiante') {
    $estudianteId = $datos['estudiante_id'] ?? null;
    if (!$estudianteId) {
        http_response_code(400);
        echo json_encode(['error' => 'Falta estudiante_id.']);
        exit;
    }

    $stmt = $pdo->prepare(
        "SELECT c.id, c.fecha_hora, c.estado, c.motivo,
                u.nombre_completo AS profesional_nombre
         FROM citas c
         LEFT JOIN usuarios u ON u.id = c.profesional_id
         WHERE c.estudiante_id = :id
         ORDER BY c.fecha_hora DESC"
    );
    $stmt->execute(['id' => $estudianteId]);
    $citas = $stmt->fetchAll(PDO::FETCH_ASSOC);

} elseif ($rol === 'bienestar') {
    $profesionalId = $datos['profesional_id'] ?? null; // opcional: filtrar solo las propias
    $estadoFiltro = $datos['estado'] ?? null;

    $sql = "SELECT c.id, c.fecha_hora, c.estado, c.motivo,
                   ue.nombre_completo AS estudiante_nombre,
                   ue.programa_academico,
                   up.nombre_completo AS profesional_nombre
            FROM citas c
            JOIN usuarios ue ON ue.id = c.estudiante_id
            LEFT JOIN usuarios up ON up.id = c.profesional_id
            WHERE 1=1";
    $params = [];

    if ($profesionalId) {
        $sql .= " AND c.profesional_id = :profesional_id";
        $params['profesional_id'] = $profesionalId;
    }
    if ($estadoFiltro) {
        $sql .= " AND c.estado = :estado";
        $params['estado'] = $estadoFiltro;
    }
    $sql .= " ORDER BY c.fecha_hora ASC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $citas = $stmt->fetchAll(PDO::FETCH_ASSOC);

} else {
    http_response_code(400);
    echo json_encode(['error' => 'Rol no reconocido.']);
    exit;
}

echo json_encode(['citas' => $citas]);
