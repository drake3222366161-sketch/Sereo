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

// Verificar primero que quien pide esto es Admin, usando PDO
try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'No se pudo conectar a la base de datos']);
    exit;
}

$datos = json_decode(file_get_contents('php://input'), true);
$adminId = $datos['admin_id'] ?? null;
$contenidoSql = $datos['contenido_sql'] ?? null;

if (!$adminId || !$contenidoSql) {
    http_response_code(400);
    echo json_encode(['error' => 'Faltan datos (admin_id o contenido_sql).']);
    exit;
}

$stmt = $pdo->prepare('SELECT rol FROM usuarios WHERE id = :id LIMIT 1');
$stmt->execute(['id' => $adminId]);
$usuarioQuePide = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$usuarioQuePide || $usuarioQuePide['rol'] !== 'admin') {
    registrarLog($pdo, 'RESTAURACION_DENEGADA', 'backup', $adminId, [], 'denegado');
    http_response_code(403);
    echo json_encode(['error' => 'Solo un administrador puede restaurar la base de datos.']);
    exit;
}

// Guardamos quién es el admin ANTES de restaurar (la tabla usuarios puede cambiar)
$actorRestaurar = auditObtenerActor($pdo, $adminId);

// Usamos mysqli (no PDO) porque mysqli->multi_query() sí sabe ejecutar un
// archivo .sql completo con muchas sentencias separadas por ";", respetando
// los ";" que puedan venir dentro del propio texto de los datos (por ejemplo,
// en el campo "nota" de una solicitud SOS). Partir el texto nosotros mismos
// por ";" a mano sería mucho más frágil y rompería con datos así.
$mysqli = new mysqli($host, $user, $pass, $db);
if ($mysqli->connect_errno) {
    http_response_code(500);
    echo json_encode(['error' => 'No se pudo conectar con mysqli: ' . $mysqli->connect_error]);
    exit;
}

$exito = $mysqli->multi_query($contenidoSql);

if ($exito) {
    // Hay que "consumir" todos los resultados de cada sentencia del script
    // antes de poder confirmar que no hubo errores en ninguna.
    do {
        if ($resultado = $mysqli->store_result()) {
            $resultado->free();
        }
    } while ($mysqli->more_results() && $mysqli->next_result());
}

if ($mysqli->errno) {
    registrarLog($pdo, 'RESTAURACION_FALLIDA', 'backup', $actorRestaurar, ['error' => substr($mysqli->error, 0, 200)], 'error');
    http_response_code(500);
    echo json_encode(['error' => 'Error al restaurar: ' . $mysqli->error]);
    $mysqli->close();
    exit;
}

$mysqli->close();

registrarLog($pdo, 'RESTAURACION_EJECUTADA', 'backup', $actorRestaurar, ['bytes' => strlen($contenidoSql)]);

echo json_encode(['mensaje' => 'Base de datos restaurada correctamente.']);

