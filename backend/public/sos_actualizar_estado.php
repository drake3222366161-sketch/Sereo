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

$solicitudId = $datos['solicitud_id'] ?? null;
$nuevoEstado = $datos['nuevo_estado'] ?? null;
$usuarioQueCambia = $datos['usuario_id'] ?? null; // quién hace el cambio

$estadosValidos = ['pendiente', 'en_proceso', 'atendida', 'cancelada'];

if (!$solicitudId || !$nuevoEstado || !$usuarioQueCambia || !in_array($nuevoEstado, $estadosValidos)) {
    http_response_code(400);
    echo json_encode(['error' => 'Datos incompletos o estado inválido.']);
    exit;
}

// 1. Buscar la solicitud actual
$stmt = $pdo->prepare('SELECT * FROM solicitudes_sos WHERE id = :id LIMIT 1');
$stmt->execute(['id' => $solicitudId]);
$solicitud = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$solicitud) {
    http_response_code(404);
    echo json_encode(['error' => 'La solicitud no existe.']);
    exit;
}

// 2. Regla: un estudiante solo puede cancelar su PROPIA solicitud,
//    y solo si sigue en estado 'pendiente'
if ($nuevoEstado === 'cancelada') {
    if ((int) $solicitud['estudiante_id'] !== (int) $usuarioQueCambia) {
        registrarLog($pdo, 'SOS_ACCION_DENEGADA', 'sos', $usuarioQueCambia, ['solicitud_id' => (int) $solicitudId, 'intento' => 'cancelar_ajena'], 'denegado');
        http_response_code(403);
        echo json_encode(['error' => 'No puedes cancelar una solicitud que no es tuya.']);
        exit;
    }
    if ($solicitud['estado'] !== 'pendiente') {
        http_response_code(409);
        echo json_encode(['error' => 'Solo puedes cancelar mientras la solicitud está pendiente.']);
        exit;
    }
}

$estadoAnterior = $solicitud['estado'];

// 3. Actualizar la solicitud
$stmt = $pdo->prepare(
    'UPDATE solicitudes_sos
     SET estado = :estado, atendido_por = :atendido_por, fecha_actualizacion = NOW()
     WHERE id = :id'
);
$stmt->execute([
    'estado' => $nuevoEstado,
    // Si es bienestar quien cambia el estado, queda registrado como quien la atiende
    'atendido_por' => $nuevoEstado === 'cancelada' ? $solicitud['atendido_por'] : $usuarioQueCambia,
    'id' => $solicitudId,
]);

// 4. Guardar la trazabilidad del cambio (criterio de aceptación HU-BIEN-002)
$stmt = $pdo->prepare(
    'INSERT INTO historial_estados_sos (solicitud_id, estado_anterior, estado_nuevo, cambiado_por)
     VALUES (:solicitud_id, :anterior, :nuevo, :cambiado_por)'
);
$stmt->execute([
    'solicitud_id' => $solicitudId,
    'anterior' => $estadoAnterior,
    'nuevo' => $nuevoEstado,
    'cambiado_por' => $usuarioQueCambia,
]);

registrarLog($pdo, 'SOS_ESTADO_CAMBIADO', 'sos', $usuarioQueCambia, ['solicitud_id' => (int) $solicitudId, 'estado_anterior' => $estadoAnterior, 'estado_nuevo' => $nuevoEstado]);

echo json_encode(['mensaje' => 'Estado actualizado correctamente.']);

