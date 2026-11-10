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

// Mismos valores que el desplegable de registro_screen.dart
const PROGRAMAS_VALIDOS = [
    'Administración de Empresas',
    'Contaduría Pública',
    'Zootecnia',
    'Ingeniería de Sistemas y Computación',
    'Ingeniería Electrónica',
    'Ciencias Sociales',
    'Educación Física',
];

function largoTexto(string $s): int
{
    return (int) preg_match_all('/./us', $s);
}

function textoLimpio($valor): string
{
    return is_scalar($valor) ? trim((string) $valor) : '';
}

/** Devuelve el teléfono sin espacios/guiones, o null si no es válido (7 a 15 dígitos, "+" opcional). */
function normalizarTelefono(string $t): ?string
{
    $t = preg_replace('/[\s\-().]/', '', $t);
    return preg_match('/^\+?\d{7,15}$/', $t) ? $t : null;
}

function responderErrorPerfil(string $codigo, string $mensaje): void
{
    http_response_code(400);
    echo json_encode(['error' => $mensaje, 'codigo' => $codigo], JSON_UNESCAPED_UNICODE);
    exit;
}

$datos = json_decode(file_get_contents('php://input'), true) ?? [];

$u = requerirSesion($pdo, $datos['usuario_id'] ?? null, $datos['token_sesion'] ?? null, ['estudiante']);

// ---------- Validación ----------
$nombre = textoLimpio($datos['nombre_completo'] ?? '');
if (largoTexto($nombre) < 3 || largoTexto($nombre) > 150) {
    responderErrorPerfil('nombre_invalido', 'El nombre debe tener entre 3 y 150 caracteres.');
}

$programa = textoLimpio($datos['programa_academico'] ?? '');
if ($programa === '' || (!in_array($programa, PROGRAMAS_VALIDOS, true) && $programa !== (string) $u['programa_academico'])) {
    responderErrorPerfil('programa_invalido', 'Selecciona un programa académico válido.');
}

$semestre = null;
$semestreRaw = $datos['semestre'] ?? null;
if ($semestreRaw !== null && $semestreRaw !== '') {
    $semestre = filter_var($semestreRaw, FILTER_VALIDATE_INT);
    if ($semestre === false || $semestre < 1 || $semestre > 12) {
        responderErrorPerfil('semestre_invalido', 'El semestre debe estar entre 1 y 12.');
    }
}

$telefono = null;
$telefonoRaw = textoLimpio($datos['telefono'] ?? '');
if ($telefonoRaw !== '') {
    $telefono = normalizarTelefono($telefonoRaw);
    if ($telefono === null) {
        responderErrorPerfil('telefono_invalido', 'El teléfono no es válido.');
    }
}

$contactoNombre = textoLimpio($datos['contacto_emergencia_nombre'] ?? '');
$contactoTelRaw = textoLimpio($datos['contacto_emergencia_telefono'] ?? '');
$contactoTel = null;
if ($contactoNombre !== '' || $contactoTelRaw !== '') {
    if ($contactoNombre === '' || $contactoTelRaw === '') {
        responderErrorPerfil('contacto_incompleto', 'Completa el nombre y el teléfono del contacto de emergencia.');
    }
    if (largoTexto($contactoNombre) < 2 || largoTexto($contactoNombre) > 150) {
        responderErrorPerfil('contacto_nombre_invalido', 'El nombre del contacto no es válido.');
    }
    $contactoTel = normalizarTelefono($contactoTelRaw);
    if ($contactoTel === null) {
        responderErrorPerfil('contacto_telefono_invalido', 'El teléfono del contacto no es válido.');
    }
} else {
    $contactoNombre = null;
}

// ---------- Guardado ----------
try {
    $st = $pdo->prepare(
        'SELECT semestre, telefono, contacto_emergencia_nombre, contacto_emergencia_telefono
         FROM perfil_estudiante WHERE usuario_id = :id LIMIT 1'
    );
    $st->execute(['id' => $u['id']]);
    $antes = $st->fetch(PDO::FETCH_ASSOC) ?: [];

    // Solo se registran los NOMBRES de los campos que cambiaron, nunca sus valores.
    $cambios = [];
    if ($nombre !== $u['nombre_completo']) $cambios[] = 'nombre';
    if ($programa !== (string) $u['programa_academico']) $cambios[] = 'programa';
    $semestreAntes = isset($antes['semestre']) ? (int) $antes['semestre'] : null;
    if ($semestre !== $semestreAntes) $cambios[] = 'semestre';
    if ($telefono !== ($antes['telefono'] ?? null)) $cambios[] = 'telefono';
    if ($contactoNombre !== ($antes['contacto_emergencia_nombre'] ?? null)) $cambios[] = 'contacto_nombre';
    if ($contactoTel !== ($antes['contacto_emergencia_telefono'] ?? null)) $cambios[] = 'contacto_telefono';

    $pdo->beginTransaction();

    $st = $pdo->prepare('UPDATE usuarios SET nombre_completo = :n, programa_academico = :p WHERE id = :id');
    $st->execute(['n' => $nombre, 'p' => $programa, 'id' => $u['id']]);

    $st = $pdo->prepare(
        'INSERT INTO perfil_estudiante
            (usuario_id, semestre, telefono, contacto_emergencia_nombre, contacto_emergencia_telefono)
         VALUES (:id, :sem, :tel, :cn, :ct)
         ON DUPLICATE KEY UPDATE
            semestre = VALUES(semestre),
            telefono = VALUES(telefono),
            contacto_emergencia_nombre = VALUES(contacto_emergencia_nombre),
            contacto_emergencia_telefono = VALUES(contacto_emergencia_telefono)'
    );
    $st->execute([
        'id' => $u['id'],
        'sem' => $semestre,
        'tel' => $telefono,
        'cn' => $contactoNombre,
        'ct' => $contactoTel,
    ]);

    $pdo->commit();
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    error_log('SEREO perfil_guardar: ' . $e->getMessage());
    registrarLog($pdo, 'PERFIL_ACTUALIZACION_FALLIDA', 'perfil', $u, ['motivo' => 'error_servidor'], 'error');
    http_response_code(500);
    echo json_encode(['error' => 'No se pudo guardar el perfil.', 'codigo' => 'error_servidor']);
    exit;
}

if ($cambios) {
    registrarLog($pdo, 'PERFIL_ACTUALIZADO', 'perfil', $u, ['campos' => $cambios]);
}

echo json_encode([
    'mensaje' => 'Perfil actualizado.',
    'nombre_completo' => $nombre,
    'programa_academico' => $programa,
], JSON_UNESCAPED_UNICODE);
