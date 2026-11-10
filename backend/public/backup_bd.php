<?php

require_once __DIR__ . '/../lib/audit.php';

$host = 'localhost';
$db   = 'sereodb';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo 'No se pudo conectar a la base de datos';
    exit;
}

// Verificación de que quien pide el backup realmente es Admin
$adminId = $_GET['admin_id'] ?? null;
if (!$adminId) {
    http_response_code(400);
    echo 'Falta admin_id.';
    exit;
}
$stmt = $pdo->prepare('SELECT rol FROM usuarios WHERE id = :id LIMIT 1');
$stmt->execute(['id' => $adminId]);
$usuario = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$usuario || $usuario['rol'] !== 'admin') {
    registrarLog($pdo, 'BACKUP_DENEGADO', 'backup', $adminId, [], 'denegado');
    http_response_code(403);
    echo 'Solo un administrador puede generar el backup.';
    exit;
}

$sql = "-- Backup de SEREO (base de datos: $db)\n";
$sql .= "-- Generado: " . date('Y-m-d H:i:s') . "\n\n";
$sql .= "SET FOREIGN_KEY_CHECKS=0;\n\n";

$tablas = $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
// Los logs de auditoría NO van en el backup: así restaurar un backup viejo
// nunca borra el historial reciente (ni la evidencia de la propia restauración).
$tablas = array_values(array_filter($tablas, fn($t) => $t !== 'audit_logs'));

foreach ($tablas as $tabla) {
    $sql .= "-- -----------------------------------------\n";
    $sql .= "-- Tabla: $tabla\n";
    $sql .= "-- -----------------------------------------\n";
    $sql .= "DROP TABLE IF EXISTS `$tabla`;\n";

    $crear = $pdo->query("SHOW CREATE TABLE `$tabla`")->fetch(PDO::FETCH_ASSOC);
    $sql .= $crear['Create Table'] . ";\n\n";

    $filas = $pdo->query("SELECT * FROM `$tabla`")->fetchAll(PDO::FETCH_ASSOC);
    foreach ($filas as $fila) {
        $columnas = array_map(fn($c) => "`$c`", array_keys($fila));
        $valores = array_map(
            fn($v) => $v === null ? 'NULL' : $pdo->quote($v),
            array_values($fila)
        );
        $sql .= 'INSERT INTO `' . $tabla . '` (' . implode(', ', $columnas) . ') VALUES ('
            . implode(', ', $valores) . ");\n";
    }
    $sql .= "\n";
}

$sql .= "SET FOREIGN_KEY_CHECKS=1;\n";

registrarLog($pdo, 'BACKUP_GENERADO', 'backup', $adminId, ['tablas' => count($tablas), 'bytes' => strlen($sql)]);

header('Content-Type: application/sql');
header('Content-Disposition: attachment; filename="sereo_backup_' . date('Y-m-d_His') . '.sql"');
echo $sql;

