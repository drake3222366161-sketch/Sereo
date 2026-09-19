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

$citaId = $datos['cita_id'] ?? null;
$accion = $datos['accion'] ?? null; // 'confirmar' | 'cancelar' | 'reagendar' | 'atendida'
$usuarioId = $datos['usuario_id'] ?? null;

if (!$citaId || !$accion || !$usuarioId) {
    http_response_code(400);
    echo json_encode(['error' => 'Datos incompletos.']);
    exit;
}

$stmt = $pdo->prepare('SELECT * FROM citas WHERE id = :id LIMIT 1');
$stmt->execute(['id' => $citaId]);
$cita = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$cita) {
    http_response_code(404);
    echo json_encode(['error' => 'La cita no existe.']);
    exit;
}

switch ($accion) {
    case 'cancelar':
        // La puede cancelar el propio estudiante dueño, o el profesional asignado
        $esDueno = (int) $cita['estudiante_id'] === (int) $usuarioId;
        $esProfesional = (int) $cita['profesional_id'] === (int) $usuarioId;

        if (!$esDueno && !$esProfesional) {
            http_response_code(403);
            echo json_encode(['error' => 'No tienes permiso para cancelar esta cita.']);
            exit;
        }
        $stmt = $pdo->prepare("UPDATE citas SET estado = 'cancelada' WHERE id = :id");
        $stmt->execute(['id' => $citaId]);
        echo json_encode(['mensaje' => 'Cita cancelada.']);
        break;

    case 'confirmar':
        // Solo el profesional asignado puede confirmar
        if ((int) $cita['profesional_id'] !== (int) $usuarioId) {
            http_response_code(403);
            echo json_encode(['error' => 'Solo el profesional asignado puede confirmar esta cita.']);
            exit;
        }
        $stmt = $pdo->prepare("UPDATE citas SET estado = 'confirmada' WHERE id = :id");
        $stmt->execute(['id' => $citaId]);
        echo json_encode(['mensaje' => 'Cita confirmada.']);
        break;

    case 'atendida':
        if ((int) $cita['profesional_id'] !== (int) $usuarioId) {
            http_response_code(403);
            echo json_encode(['error' => 'Solo el profesional asignado puede marcarla como atendida.']);
            exit;
        }
        $stmt = $pdo->prepare("UPDATE citas SET estado = 'atendida' WHERE id = :id");
        $stmt->execute(['id' => $citaId]);
        echo json_encode(['mensaje' => 'Cita marcada como atendida.']);
        break;

    case 'reagendar':
        if ((int) $cita['profesional_id'] !== (int) $usuarioId) {
            http_response_code(403);
            echo json_encode(['error' => 'Solo el profesional asignado puede reagendar esta cita.']);
            exit;
        }

        $nuevaFecha = $datos['nueva_fecha'] ?? null;
        $nuevaHora = $datos['nueva_hora'] ?? null;

        if (!$nuevaFecha || !$nuevaHora) {
            http_response_code(400);
            echo json_encode(['error' => 'Falta la nueva fecha/hora.']);
            exit;
        }

        // Verificar que el nuevo horario no esté ya ocupado por otra cita activa
        $stmt = $pdo->prepare(
            "SELECT COUNT(*) AS total FROM citas
             WHERE profesional_id = :profesional_id
               AND fecha_hora = TIMESTAMP(:fecha, :hora)
               AND estado NOT IN ('cancelada')
               AND id != :cita_id"
        );
        $stmt->execute([
            'profesional_id' => $cita['profesional_id'],
            'fecha' => $nuevaFecha,
            'hora' => $nuevaHora,
            'cita_id' => $citaId,
        ]);
        if ((int) $stmt->fetch()['total'] > 0) {
            http_response_code(409);
            echo json_encode(['error' => 'Ese nuevo horario ya está ocupado.']);
            exit;
        }

        $stmt = $pdo->prepare(
            "UPDATE citas SET fecha_hora = TIMESTAMP(:fecha, :hora), estado = 'reagendada' WHERE id = :id"
        );
        $stmt->execute(['fecha' => $nuevaFecha, 'hora' => $nuevaHora, 'id' => $citaId]);
        echo json_encode(['mensaje' => 'Cita reagendada.']);
        break;

    default:
        http_response_code(400);
        echo json_encode(['error' => 'Acción no reconocida.']);
}
