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
        'SELECT id, puntaje_total, clasificacion, fecha
         FROM autoevaluaciones WHERE estudiante_id = :id ORDER BY fecha DESC'
    );
    $stmt->execute(['id' => $estudianteId]);
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

} elseif ($rol === 'bienestar') {
    // Bienestar ve todas, con el nombre/programa del estudiante -
    // esta es información sensible, solo accesible desde este rol.
    $clasificacionFiltro = $datos['clasificacion'] ?? null;

    $sql = "SELECT a.id, a.puntaje_total, a.clasificacion, a.fecha,
                   u.nombre_completo AS estudiante_nombre,
                   u.programa_academico
            FROM autoevaluaciones a
            JOIN usuarios u ON u.id = a.estudiante_id";
    $params = [];
    if ($clasificacionFiltro) {
        $sql .= ' WHERE a.clasificacion = :clasificacion';
        $params['clasificacion'] = $clasificacionFiltro;
    }
    $sql .= ' ORDER BY a.fecha DESC';

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

} else {
    http_response_code(400);
    echo json_encode(['error' => 'Rol no reconocido.']);
    exit;
}

echo json_encode(['resultados' => $resultados]);
