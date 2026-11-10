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
registrarLog($pdo, 'REPORTE_SOS_EXPORTADO', 'reportes', $_GET['usuario_id'] ?? null, ['formato' => 'xls']);

$stmt = $pdo->query(
    "SELECT s.id, u.nombre_completo AS estudiante, u.correo, u.programa_academico,
            s.estado, s.nota, s.telefono_contacto, s.fecha_solicitud, s.fecha_actualizacion
     FROM solicitudes_sos s
     JOIN usuarios u ON u.id = s.estudiante_id
     ORDER BY s.fecha_solicitud DESC"
);
$filas = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Configuración de cabeceras para descarga en formato Excel (.xls)
header('Content-Type: application/vnd.ms-excel; charset=utf-8');
header('Content-Disposition: attachment; filename="sereo_reporte_sos_' . date('Y-m-d') . '.xls"');
header('Pragma: no-cache');
header('Expires: 0');

// BOM UTF-8 para asegurar la correcta lectura de tildes y eñes
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
        
        /* Forzar formato de texto para teléfonos y fechas (evita notación científica o reformatado raro) */
        .mso-text { mso-number-format:"\@"; }

        /* Semáforo de estados para solicitudes SOS */
        .estado-pendiente  { background-color: #FCE4D6; color: #C65911; font-weight: bold; text-align: center; } /* Rojo/Naranja suave */
        .estado-proceso    { background-color: #FFF2CC; color: #B25900; font-weight: bold; text-align: center; } /* Amarillo suave */
        .estado-completada { background-color: #E2F0D9; color: #385723; font-weight: bold; text-align: center; } /* Verde suave */
    </style>
</head>
<body>
    <table border="1">
        <thead>
            <tr>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 60px;">ID</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 220px;">Estudiante</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 220px;">Correo</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 200px;">Programa académico</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 130px;">Estado</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 250px;">Nota</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 130px;">Teléfono</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 160px;">Fecha solicitud</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 160px;">Última actualización</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($filas as $f): ?>
                <?php 
                    // Limpieza del estado para asignación de color
                    $estadoClean = mb_strtolower(trim($f['estado']));
                    $claseEstado = 'txt-center';
                    
                    if (strpos($estadoClean, 'pendient') !== false || strpos($estadoClean, 'urgente') !== false || strpos($estadoClean, 'sin atender') !== false) {
                        $claseEstado = 'estado-pendiente';  // Alerta alta
                    } elseif (strpos($estadoClean, 'proceso') !== false || strpos($estadoClean, 'atencion') !== false || strpos($estadoClean, 'atención') !== false) {
                        $claseEstado = 'estado-proceso';    // En revisión
                    } elseif (strpos($estadoClean, 'resuelt') !== false || strpos($estadoClean, 'atendid') !== false || strpos($estadoClean, 'cerrad') !== false) {
                        $claseEstado = 'estado-completada'; // Finalizado
                    }
                ?>
                <tr>
                    <td class="txt-center"><?= htmlspecialchars($f['id']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['estudiante']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['correo']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['programa_academico']) ?></td>
                    <td class="<?= $claseEstado ?>"><?= htmlspecialchars($f['estado']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['nota'] ?? '') ?></td>
                    <td class="txt-center mso-text"><?= htmlspecialchars($f['telefono_contacto'] ?? 'N/R') ?></td>
                    <td class="txt-center mso-text"><?= htmlspecialchars($f['fecha_solicitud']) ?></td>
                    <td class="txt-center mso-text"><?= htmlspecialchars($f['fecha_actualizacion'] ?? '') ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>
<?php
exit;
