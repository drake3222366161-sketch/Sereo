<?php

require_once __DIR__ . '/../lib/audit.php';
require_once __DIR__ . '/../lib/auth.php';

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

// Solo un estudiante con sesión vigente puede ver SU perfil (el id sale de la sesión validada).
$u = requerirSesion($pdo, $datos['usuario_id'] ?? null, $datos['token_sesion'] ?? null, ['estudiante']);

try {
    $st = $pdo->prepare('SELECT politica_aceptada, politica_aceptada_fecha FROM usuarios WHERE id = :id LIMIT 1');
    $st->execute(['id' => $u['id']]);
    $pol = $st->fetch(PDO::FETCH_ASSOC) ?: [];

    $st = $pdo->prepare(
        'SELECT semestre, telefono, contacto_emergencia_nombre, contacto_emergencia_telefono
         FROM perfil_estudiante WHERE usuario_id = :id LIMIT 1'
    );
    $st->execute(['id' => $u['id']]);
    $p = $st->fetch(PDO::FETCH_ASSOC) ?: [];
} catch (Throwable $e) {
    error_log('SEREO perfil_obtener: ' . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'No se pudo cargar el perfil.', 'codigo' => 'error_servidor']);
    exit;
}

echo json_encode([
    'perfil' => [
        'nombre_completo' => $u['nombre_completo'],
        'correo' => $u['correo'],
        'programa_academico' => $u['programa_academico'],
        'politica_aceptada' => !empty($pol['politica_aceptada']),
        'politica_aceptada_fecha' => $pol['politica_aceptada_fecha'] ?? null,
        'semestre' => isset($p['semestre']) ? (int) $p['semestre'] : null,
        'telefono' => $p['telefono'] ?? null,
        'contacto_emergencia_nombre' => $p['contacto_emergencia_nombre'] ?? null,
        'contacto_emergencia_telefono' => $p['contacto_emergencia_telefono'] ?? null,
    ],
], JSON_UNESCAPED_UNICODE);
