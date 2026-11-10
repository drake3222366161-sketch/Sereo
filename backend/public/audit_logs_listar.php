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

$datos = json_decode(file_get_contents('php://input'), true) ?? [];
$adminId = $datos['admin_id'] ?? null;

if (!$adminId) {
    http_response_code(400);
    echo json_encode(['error' => 'Falta admin_id.']);
    exit;
}

// Solo un administrador puede ver los logs (se verifica el rol en la base de datos)
$actor = auditObtenerActor($pdo, $adminId);
if (!$actor || ($actor['rol'] ?? null) !== 'admin') {
    registrarLog($pdo, 'ACCESO_LOGS_DENEGADO', 'auditoria', $actor ?? (int) $adminId, [], 'denegado');
    http_response_code(403);
    echo json_encode(['error' => 'Solo un administrador puede consultar los logs.']);
    exit;
}

// ---- Filtros (todos opcionales) ----
$where = [];
$params = [];

$fechaOk = fn($v) => is_string($v) && preg_match('/^\d{4}-\d{2}-\d{2}$/', $v);

if (!empty($datos['desde']) && $fechaOk($datos['desde'])) {
    $where[] = 'fecha >= :desde';
    $params['desde'] = $datos['desde'] . ' 00:00:00';
}
if (!empty($datos['hasta']) && $fechaOk($datos['hasta'])) {
    $where[] = 'fecha <= :hasta';
    $params['hasta'] = $datos['hasta'] . ' 23:59:59';
}
if (!empty($datos['usuario']) && is_string($datos['usuario'])) {
    $where[] = '(correo LIKE :usuario OR usuario_id = :usuario_id)';
    $params['usuario'] = '%' . trim($datos['usuario']) . '%';
    $params['usuario_id'] = is_numeric(trim($datos['usuario'])) ? (int) trim($datos['usuario']) : -1;
}
if (!empty($datos['modulo']) && is_string($datos['modulo'])) {
    $where[] = 'modulo = :modulo';
    $params['modulo'] = $datos['modulo'];
}
if (!empty($datos['accion']) && is_string($datos['accion'])) {
    $where[] = 'accion = :accion';
    $params['accion'] = $datos['accion'];
}
if (!empty($datos['resultado']) && in_array($datos['resultado'], ['ok', 'error', 'denegado'], true)) {
    $where[] = 'resultado = :resultado';
    $params['resultado'] = $datos['resultado'];
}
$condicion = $where ? ('WHERE ' . implode(' AND ', $where)) : '';

// ---- Paginación ----
$porPagina = max(1, min(100, (int) ($datos['por_pagina'] ?? 25)));
$pagina = max(1, (int) ($datos['pagina'] ?? 1));
$offset = ($pagina - 1) * $porPagina;

try {
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM audit_logs $condicion");
    $stmt->execute($params);
    $total = (int) $stmt->fetchColumn();

    $stmt = $pdo->prepare(
        "SELECT id, fecha, usuario_id, correo, rol, accion, modulo, resultado, detalle, ip
         FROM audit_logs $condicion
         ORDER BY id DESC
         LIMIT $porPagina OFFSET $offset"
    );
    $stmt->execute($params);
    $logs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Listas para llenar los filtros de la pantalla
    $modulos = $pdo->query('SELECT DISTINCT modulo FROM audit_logs ORDER BY modulo')->fetchAll(PDO::FETCH_COLUMN);
    $acciones = $pdo->query('SELECT DISTINCT accion FROM audit_logs ORDER BY accion')->fetchAll(PDO::FETCH_COLUMN);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'No se pudieron leer los logs. ¿Ya creaste la tabla audit_logs?']);
    exit;
}

// Consultar los logs también queda registrado (máx. 1 vez cada 5 min por admin, para no llenar de ruido)
registrarLog($pdo, 'LOGS_CONSULTADOS', 'auditoria', $actor, [], 'ok', null, 300);

echo json_encode([
    'total' => $total,
    'pagina' => $pagina,
    'por_pagina' => $porPagina,
    'logs' => $logs,
    'modulos' => $modulos,
    'acciones' => $acciones,
], JSON_INVALID_UTF8_SUBSTITUTE);
