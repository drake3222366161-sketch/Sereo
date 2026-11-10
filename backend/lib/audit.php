<?php
/**
 * SEREO - Auditoría (logs del sistema).
 *
 * Uso desde cualquier endpoint de backend/public:
 *     require_once __DIR__ . '/../lib/audit.php';
 *     registrarLog($pdo, 'CITA_CREADA', 'citas', $estudianteId, ['cita_id' => 5]);
 *
 * Reglas de oro:
 *  - Esta tabla es SOLO de inserción: ningún endpoint la modifica ni la borra.
 *  - NUNCA se guardan contraseñas, tokens ni contenido clínico (notas SOS,
 *    respuestas o puntajes de autoevaluación, diario). Solo el hecho y los IDs.
 *  - Si falla el log, la app NO se cae: el error va al log de PHP y se sigue.
 */

/**
 * Busca id, correo y rol de un usuario. Si no existe, devuelve solo el id.
 */
function auditObtenerActor(PDO $pdo, $usuarioId): ?array
{
    if ($usuarioId === null || $usuarioId === '' || !is_numeric($usuarioId)) {
        return null;
    }
    $vacio = ['id' => (int) $usuarioId, 'correo' => null, 'rol' => null];
    try {
        $st = $pdo->prepare('SELECT id, correo, rol FROM usuarios WHERE id = :id LIMIT 1');
        $st->execute(['id' => (int) $usuarioId]);
        $u = $st->fetch(PDO::FETCH_ASSOC);
        return $u ?: $vacio;
    } catch (Throwable $e) {
        return $vacio;
    }
}

/** Quita del detalle cualquier campo que parezca contraseña, token o hash. */
function auditLimpiarDetalle($valor)
{
    if (!is_array($valor)) {
        return $valor;
    }
    $limpio = [];
    foreach ($valor as $k => $v) {
        if (is_string($k) && preg_match('/contrasena|password|clave|token|hash/i', $k)) {
            continue;
        }
        $limpio[$k] = auditLimpiarDetalle($v);
    }
    return $limpio;
}

/**
 * Registra un evento.
 *
 * @param PDO               $pdo
 * @param string            $accion   Ej: LOGIN_EXITOSO, CITA_CREADA
 * @param string            $modulo   Ej: auth, citas, usuarios, sos, backup
 * @param int|array|null    $actor    id del usuario, o array ['id','correo','rol'], o null
 * @param array             $detalle  Datos extra (se guardan como JSON)
 * @param string            $resultado 'ok' | 'error' | 'denegado'
 * @param string|null       $correoIntentado Para logins fallidos sin usuario conocido
 * @param int               $dedupSegundos Si > 0, no repite la misma acción del mismo
 *                                         usuario dentro de esa ventana de tiempo
 */
function registrarLog(
    PDO $pdo,
    string $accion,
    string $modulo,
    $actor = null,
    array $detalle = [],
    string $resultado = 'ok',
    ?string $correoIntentado = null,
    int $dedupSegundos = 0
): void {
    try {
        if (is_array($actor)) {
            $usuarioId = isset($actor['id']) ? (int) $actor['id'] : null;
            $correo = $actor['correo'] ?? null;
            $rol = $actor['rol'] ?? null;
        } else {
            $info = auditObtenerActor($pdo, $actor);
            $usuarioId = $info['id'] ?? null;
            $correo = $info['correo'] ?? null;
            $rol = $info['rol'] ?? null;
        }
        if ($correo === null && $correoIntentado !== null) {
            $correo = substr($correoIntentado, 0, 150);
        }

        if ($dedupSegundos > 0 && $usuarioId !== null) {
            $seg = (int) $dedupSegundos;
            $st = $pdo->prepare(
                "SELECT 1 FROM audit_logs
                 WHERE usuario_id = :u AND accion = :a
                   AND fecha >= (NOW() - INTERVAL $seg SECOND) LIMIT 1"
            );
            $st->execute(['u' => $usuarioId, 'a' => $accion]);
            if ($st->fetchColumn()) {
                return;
            }
        }

        $json = null;
        if (!empty($detalle)) {
            $json = json_encode(
                auditLimpiarDetalle($detalle),
                JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
            );
            if ($json === false || strlen($json) > 2000) {
                $json = '{"truncado":true}';
            }
        }

        if (!in_array($resultado, ['ok', 'error', 'denegado'], true)) {
            $resultado = 'ok';
        }

        $st = $pdo->prepare(
            'INSERT INTO audit_logs (usuario_id, correo, rol, accion, modulo, resultado, detalle, ip)
             VALUES (:usuario_id, :correo, :rol, :accion, :modulo, :resultado, :detalle, :ip)'
        );
        $st->execute([
            'usuario_id' => $usuarioId,
            'correo' => $correo,
            'rol' => $rol,
            'accion' => substr($accion, 0, 60),
            'modulo' => substr($modulo, 0, 40),
            'resultado' => $resultado,
            'detalle' => $json,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? null,
        ]);
    } catch (Throwable $e) {
        // El log nunca debe tumbar la aplicación.
        error_log('SEREO audit: ' . $e->getMessage());
    }
}
