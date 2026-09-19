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
$rolFiltro = $datos['rol_filtro'] ?? null; // null = todos

$sql = 'SELECT id, nombre_completo, correo, rol, programa_academico, activo, fecha_creacion
        FROM usuarios';
$params = [];

if ($rolFiltro) {
    $sql .= ' WHERE rol = :rol';
    $params['rol'] = $rolFiltro;
}
$sql .= ' ORDER BY fecha_creacion DESC';

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);

echo json_encode(['usuarios' => $usuarios]);
