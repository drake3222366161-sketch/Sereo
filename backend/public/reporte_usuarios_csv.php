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

// Auditoría: quién exportó el reporte (la app envía ?usuario_id=)
registrarLog($pdo, 'REPORTE_USUARIOS_EXPORTADO', 'reportes', $_GET['usuario_id'] ?? null, ['formato' => 'xls']);

$stmt = $pdo->query(
    "SELECT id, nombre_completo, correo, rol, programa_academico, activo, fecha_creacion
     FROM usuarios ORDER BY fecha_creacion DESC"
);
$filas = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Configuración de cabeceras para descarga en formato Excel (.xls)
header('Content-Type: application/vnd.ms-excel; charset=utf-8');
header('Content-Disposition: attachment; filename="sereo_reporte_usuarios_' . date('Y-m-d') . '.xls"');
header('Pragma: no-cache');
header('Expires: 0');

// BOM UTF-8 para asegurar la lectura de caracteres con tildes y eñes
echo "\xEF\xBB\xBF";
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 11pt;
        }
        table {
            border-collapse: collapse;
            width: 100%;
        }
        td {
            border: 1px solid #D9D9D9;
            padding: 8px 10px;
            vertical-align: middle;
        }
        /* Zebra striping (Filas alternas) */
        tr:nth-child(even) {
            background-color: #F8F9FA;
        }
        /* Alineaciones */
        .txt-center { text-align: center; }
        .txt-left { text-align: left; }
        
        /* Forzar formato de texto para la fecha */
        .mso-date { mso-number-format:"\@"; }

        /* Colores de estado (Activo / Inactivo) */
        .estado-activo   { background-color: #E2F0D9; color: #385723; font-weight: bold; text-align: center; } /* Verde suave */
        .estado-inactivo { background-color: #FCE4D6; color: #C65911; font-weight: bold; text-align: center; } /* Rojo/Naranja suave */

        /* Colores por Rol */
        .rol-admin        { background-color: #F2DCDB; color: #9C0006; font-weight: bold; text-align: center; } /* Púrpura/Rojo para Admin */
        .rol-profesional  { background-color: #DDEBF7; color: #1F4E79; font-weight: bold; text-align: center; } /* Azul claro para Profesional */
        .rol-estudiante   { background-color: #FFF2CC; color: #B25900; font-weight: bold; text-align: center; } /* Amarillo para Estudiante */
    </style>
</head>
<body>
    <table border="1">
        <thead>
            <tr>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 60px;">ID</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 220px;">Nombre</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 240px;">Correo</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 140px;">Rol</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 220px;">Programa académico</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 90px;">Activo</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 160px;">Fecha de creación</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($filas as $f): ?>
                <?php 
                    // Limpieza y validación de activo
                    $esActivo = (bool)$f['activo'];
                    $claseActivo = $esActivo ? 'estado-activo' : 'estado-inactivo';

                    // Asignación de color según el Rol
                    $rolClean = mb_strtolower(trim($f['rol']));
                    $claseRol = 'txt-center';

                    if (strpos($rolClean, 'admin') !== false) {
                        $claseRol = 'rol-admin';
                    } elseif (strpos($rolClean, 'profesional') !== false || strpos($rolClean, 'psicologo') !== false || strpos($rolClean, 'docente') !== false) {
                        $claseRol = 'rol-profesional';
                    } elseif (strpos($rolClean, 'estudiante') !== false) {
                        $claseRol = 'rol-estudiante';
                    }
                ?>
                <tr>
                    <td class="txt-center"><?= htmlspecialchars($f['id']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['nombre_completo']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['correo']) ?></td>
                    <td class="<?= $claseRol ?>"><?= htmlspecialchars(ucfirst($f['rol'])) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['programa_academico'] ?? 'N/A') ?></td>
                    <td class="<?= $claseActivo ?>"><?= $esActivo ? 'Sí' : 'No' ?></td>
                    <td class="txt-center mso-date"><?= htmlspecialchars($f['fecha_creacion']) ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>
<?php
exit;
