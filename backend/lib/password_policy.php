<?php
/**
 * Política de contraseñas de SEREO.
 * Guardar en: backend/lib/password_policy.php (junto a audit.php)
 *
 * La validación REAL vive aquí (servidor). La de Flutter es solo ayuda visual.
 */

const SEREO_PASSWORD_MIN = 10;

// Contraseñas demasiado comunes (en minúscula). Se puede ampliar.
const SEREO_PASSWORDS_COMUNES = [
    'password1!', 'password123!', 'contrasena1!', 'contraseña1!',
    'qwerty123!', 'admin123!', 'bienvenido1!', 'sereo2026!',
    '123456789a!', 'abcd1234!', 'ucundinamarca1!',
];

/** Cuenta caracteres (no bytes), sin depender de la extensión mbstring. */
function longitudCaracteres(string $texto): int
{
    return (int) preg_match_all('/./us', $texto);
}

/** Quita tildes y convierte la ñ en n, para comparar "María" con "maria". */
function sinTildes(string $texto): string
{
    return strtr($texto, [
        'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u', 'ü' => 'u', 'ñ' => 'n',
        'Á' => 'A', 'É' => 'E', 'Í' => 'I', 'Ó' => 'O', 'Ú' => 'U', 'Ü' => 'U', 'Ñ' => 'N',
    ]);
}

/**
 * Devuelve la lista de requisitos que NO cumple la contraseña.
 * Lista vacía = la contraseña es válida.
 *
 * Códigos posibles:
 *   longitud, mayuscula, minuscula, numero, especial,
 *   datos_personales, comun
 */
function validarPoliticaContrasena(string $contrasena, string $correo = '', string $nombre = ''): array
{
    $fallos = [];

    if (longitudCaracteres($contrasena) < SEREO_PASSWORD_MIN) {
        $fallos[] = 'longitud';
    }
    if (!preg_match('/\p{Lu}/u', $contrasena)) {
        $fallos[] = 'mayuscula';
    }
    if (!preg_match('/\p{Ll}/u', $contrasena)) {
        $fallos[] = 'minuscula';
    }
    if (!preg_match('/\d/', $contrasena)) {
        $fallos[] = 'numero';
    }
    // Carácter especial = cualquier cosa que no sea letra, número o espacio
    if (!preg_match('/[^\p{L}\p{N}\s]/u', $contrasena)) {
        $fallos[] = 'especial';
    }

    // No puede contener partes del correo ni del nombre (fragmentos de 4+ letras)
    $partes = [];
    if ($correo !== '') {
        $partes[] = explode('@', $correo)[0];
    }
    if ($nombre !== '') {
        foreach (preg_split('/\s+/u', $nombre) as $palabra) {
            $partes[] = $palabra;
        }
    }
    $contrasenaPlana = sinTildes($contrasena);
    foreach ($partes as $parte) {
        $partePlana = sinTildes($parte);
        if (strlen($partePlana) >= 4 && stripos($contrasenaPlana, $partePlana) !== false) {
            $fallos[] = 'datos_personales';
            break;
        }
    }

    if (in_array(strtolower($contrasena), SEREO_PASSWORDS_COMUNES, true)) {
        $fallos[] = 'comun';
    }

    return $fallos;
}

/**
 * Responde 400 con un código que Flutter puede traducir (es/en) y termina.
 * Nunca incluye la contraseña en la respuesta.
 */
function responderPoliticaContrasenaInvalida(array $fallos): void
{
    http_response_code(400);
    echo json_encode([
        'error' => 'La contraseña no cumple la política de seguridad.',
        'codigo' => 'password_policy',
        'requisitos_fallidos' => $fallos,
        'minimo' => SEREO_PASSWORD_MIN,
    ]);
    exit;
}
