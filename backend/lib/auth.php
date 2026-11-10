<?php
/**
 * SEREO - Validación de sesión y rol en el SERVIDOR.
 * Guardar en: backend/lib/auth.php (junto a audit.php)
 *
 * Uso en cualquier endpoint:
 *     require_once __DIR__ . '/../lib/audit.php';
 *     require_once __DIR__ . '/../lib/auth.php';
 *     $u = requerirSesion($pdo, $datos['usuario_id'] ?? null, $datos['token_sesion'] ?? null, ['estudiante']);
 *
 * Si la sesión no es válida o el rol no corresponde, responde el error y
 * termina la petición. Si todo está bien, devuelve los datos del usuario.
 * Así la restricción por rol NO depende de lo que muestre u oculte Flutter.
 */

require_once __DIR__ . '/audit.php';

function responderErrorAuth(int $http, string $mensaje, string $codigo): void
{
    http_response_code($http);
    echo json_encode(['error' => $mensaje, 'codigo' => $codigo], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * @param array $rolesPermitidos Ej: ['estudiante'] o ['admin']. Vacío = cualquier rol.
 * @return array id, nombre_completo, correo, rol, programa_academico, activo
 */
function requerirSesion(PDO $pdo, $usuarioId, $token, array $rolesPermitidos = []): array
{
    if (!is_numeric($usuarioId) || !is_string($token) || $token === '') {
        responderErrorAuth(401, 'Sesión no válida.', 'sesion_invalida');
    }

    $st = $pdo->prepare(
        'SELECT id, nombre_completo, correo, rol, programa_academico, activo, token_sesion
         FROM usuarios WHERE id = :id LIMIT 1'
    );
    $st->execute(['id' => (int) $usuarioId]);
    $u = $st->fetch(PDO::FETCH_ASSOC);

    if (
        !$u
        || !is_string($u['token_sesion'])
        || $u['token_sesion'] === ''
        || !hash_equals($u['token_sesion'], $token)
    ) {
        registrarLog(
            $pdo, 'ACCESO_SIN_SESION', 'auth', $u ?: (int) $usuarioId,
            ['motivo' => 'token_invalido', 'endpoint' => basename($_SERVER['SCRIPT_NAME'] ?? '')],
            'denegado', null, 60
        );
        responderErrorAuth(401, 'Tu sesión no es válida o fue cerrada.', 'sesion_invalida');
    }

    if (!(int) $u['activo']) {
        responderErrorAuth(403, 'Esta cuenta está desactivada.', 'cuenta_desactivada');
    }

    if ($rolesPermitidos && !in_array($u['rol'], $rolesPermitidos, true)) {
        registrarLog(
            $pdo, 'ACCESO_DENEGADO', 'auth', $u,
            [
                'motivo' => 'rol_no_permitido',
                'roles_permitidos' => implode(',', $rolesPermitidos),
                'endpoint' => basename($_SERVER['SCRIPT_NAME'] ?? ''),
            ],
            'denegado'
        );
        responderErrorAuth(403, 'No tienes permiso para esta acción.', 'sin_permiso');
    }

    unset($u['token_sesion']);
    $u['id'] = (int) $u['id'];
    return $u;
}
