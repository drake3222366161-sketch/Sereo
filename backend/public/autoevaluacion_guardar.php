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
$estudianteId = $datos['estudiante_id'] ?? null;
$respuestas = $datos['respuestas'] ?? null; // [{pregunta_id, valor}, ...]

if (!$estudianteId || !$respuestas || !is_array($respuestas) || count($respuestas) !== 9) {
    http_response_code(400);
    echo json_encode(['error' => 'Debes responder las 9 preguntas del test.']);
    exit;
}

// Validar que cada valor esté en el rango correcto (0 a 3, escala oficial del PHQ-9)
$puntajeTotal = 0;
foreach ($respuestas as $r) {
    $valor = $r['valor'] ?? null;
    if ($valor === null || $valor < 0 || $valor > 3) {
        http_response_code(400);
        echo json_encode(['error' => 'Hay respuestas con un valor fuera de rango.']);
        exit;
    }
    $puntajeTotal += (int) $valor;
}

// Clasificación oficial del PHQ-9 según el puntaje total (0 a 27)
if ($puntajeTotal <= 4) {
    $clasificacion = 'Minimo';
} elseif ($puntajeTotal <= 9) {
    $clasificacion = 'Leve';
} elseif ($puntajeTotal <= 14) {
    $clasificacion = 'Moderado';
} elseif ($puntajeTotal <= 19) {
    $clasificacion = 'Moderadamente severo';
} else {
    $clasificacion = 'Severo';
}

// La pregunta 9 (orden = 9) pregunta específicamente por pensamientos de
// autolesión - esto se revisa aparte del puntaje total, porque es una
// señal de riesgo que merece atención sin importar el resultado general.
$stmt = $pdo->prepare('SELECT id FROM preguntas_autoevaluacion WHERE orden = 9 LIMIT 1');
$stmt->execute();
$idPregunta9 = $stmt->fetch(PDO::FETCH_ASSOC)['id'] ?? null;

$alertaRiesgo = false;
foreach ($respuestas as $r) {
    if ((int) $r['pregunta_id'] === (int) $idPregunta9 && (int) $r['valor'] > 0) {
        $alertaRiesgo = true;
        break;
    }
}

// Guardar el resultado
$stmt = $pdo->prepare(
    'INSERT INTO autoevaluaciones (estudiante_id, puntaje_total, clasificacion)
     VALUES (:estudiante_id, :puntaje, :clasificacion)'
);
$stmt->execute([
    'estudiante_id' => $estudianteId,
    'puntaje' => $puntajeTotal,
    'clasificacion' => $clasificacion,
]);
$autoevaluacionId = $pdo->lastInsertId();

// Guardar el detalle de cada respuesta
$stmtDetalle = $pdo->prepare(
    'INSERT INTO respuestas_autoevaluacion (autoevaluacion_id, pregunta_id, valor_respuesta)
     VALUES (:autoevaluacion_id, :pregunta_id, :valor)'
);
foreach ($respuestas as $r) {
    $stmtDetalle->execute([
        'autoevaluacion_id' => $autoevaluacionId,
        'pregunta_id' => $r['pregunta_id'],
        'valor' => $r['valor'],
    ]);
}

// Solo el hecho: puntaje, clasificación y alerta son datos clínicos y NO van al log
registrarLog($pdo, 'AUTOEVALUACION_COMPLETADA', 'autoevaluacion', $estudianteId, ['autoevaluacion_id' => (int) $autoevaluacionId]);

echo json_encode([
    'mensaje' => 'Autoevaluación registrada.',
    'puntaje_total' => $puntajeTotal,
    'clasificacion' => $clasificacion,
    'alerta_riesgo' => $alertaRiesgo,
]);

