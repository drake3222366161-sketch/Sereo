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
    // El estudiante solo ve sus propias solicitudes
    $estudianteId = $datos['estudiante_id'] ?? null;
    if (!$estudianteId) {
        http_response_code(400);
        echo json_encode(['error' => 'Falta el estudiante_id.']);
        exit;
    }

    $stmt = $pdo->prepare(
        'SELECT id, nota, telefono_contacto, estado, fecha_solicitud, fecha_actualizacion
         FROM solicitudes_sos
         WHERE estudiante_id = :id
         ORDER BY fecha_solicitud DESC'
    );
    $stmt->execute(['id' => $estudianteId]);
    $solicitudes = $stmt->fetchAll(PDO::FETCH_ASSOC);

} elseif ($rol === 'bienestar' || $rol === 'admin') {
    // Bienestar ve todas, opcionalmente filtradas por estado.
    // (Admin puede listar también, pero solo bienestar debería gestionarlas -
    //  el frontend se encarga de no mostrarle este módulo a Admin.)
    $estadoFiltro = $datos['estado'] ?? null;

    $sql = "SELECT s.id, s.nota, s.telefono_contacto, s.estado,
                   s.fecha_solicitud, s.fecha_actualizacion,
                   u.nombre_completo AS estudiante_nombre,
                   u.correo AS estudiante_correo,
                   u.programa_academico
            FROM solicitudes_sos s
            JOIN usuarios u ON u.id = s.estudiante_id";

    $params = [];
    if ($estadoFiltro) {
        $sql .= " WHERE s.estado = :estado";
        $params['estado'] = $estadoFiltro;
    }
    $sql .= " ORDER BY s.fecha_solicitud ASC"; // las más antiguas primero (prioridad)

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $solicitudes = $stmt->fetchAll(PDO::FETCH_ASSOC);

} else {
    http_response_code(400);
    echo json_encode(['error' => 'Rol no reconocido.']);
    exit;
}

echo json_encode(['solicitudes' => $solicitudes]);
