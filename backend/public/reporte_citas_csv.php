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
registrarLog($pdo, 'REPORTE_CITAS_EXPORTADO', 'reportes', $_GET['usuario_id'] ?? null, ['formato' => 'xls']);

$stmt = $pdo->query(
    "SELECT c.id, ue.nombre_completo AS estudiante, ue.programa_academico,
            up.nombre_completo AS profesional, c.fecha_hora, c.estado, c.motivo
     FROM citas c
     JOIN usuarios ue ON ue.id = c.estudiante_id
     LEFT JOIN usuarios up ON up.id = c.profesional_id
     ORDER BY c.fecha_hora DESC"
);
$filas = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Encabezados para que el navegador lo descargue como archivo de Excel (.xls)
header('Content-Type: application/vnd.ms-excel; charset=utf-8');
header('Content-Disposition: attachment; filename="sereo_reporte_citas_' . date('Y-m-d') . '.xls"');
header('Pragma: no-cache');
header('Expires: 0');

// BOM UTF-8 para que Excel muestre tildes y eñes correctamente
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
        /* Zebra striping (Filas intercaladas) */
        tr:nth-child(even) {
            background-color: #F8F9FA;
        }
        /* Alineaciones de texto */
        .txt-center { text-align: center; }
        .txt-left { text-align: left; }
        
        /* Forzar formato de texto en fechas */
        .mso-date { mso-number-format:"\@"; }

        /* Colores dinámicos según el estado */
        .estado-completada { background-color: #E2F0D9; color: #385723; font-weight: bold; text-align: center; }
        .estado-pendiente  { background-color: #FFF2CC; color: #B25900; font-weight: bold; text-align: center; }
        .estado-cancelada  { background-color: #FCE4D6; color: #C65911; font-weight: bold; text-align: center; }
    </style>
</head>
<body>
    <table border="1">
        <thead>
            <tr>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 60px;">ID</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 220px;">Estudiante</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 200px;">Programa académico</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 220px;">Profesional</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 160px;">Fecha y hora</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 130px;">Estado</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 35px; width: 260px;">Motivo</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($filas as $f): ?>
                <?php 
                    // Limpieza del estado para validar la clase
                    $estadoClean = mb_strtolower(trim($f['estado']));
                    $claseEstado = 'txt-center';
                    
                    if (strpos($estadoClean, 'complet') !== false || strpos($estadoClean, 'atendid') !== false || strpos($estadoClean, 'realizad') !== false) {
                        $claseEstado = 'estado-completada';
                    } elseif (strpos($estadoClean, 'pendient') !== false || strpos($estadoClean, 'programad') !== false) {
                        $claseEstado = 'estado-pendiente';
                    } elseif (strpos($estadoClean, 'cancel') !== false) {
                        $claseEstado = 'estado-cancelada';
                    }
                ?>
                <tr>
                    <td class="txt-center"><?= htmlspecialchars($f['id']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['estudiante']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['programa_academico']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['profesional'] ?? 'Sin asignar') ?></td>
                    <td class="txt-center mso-date"><?= htmlspecialchars($f['fecha_hora']) ?></td>
                    <td class="<?= $claseEstado ?>"><?= htmlspecialchars($f['estado']) ?></td>
                    <td class="txt-left"><?= htmlspecialchars($f['motivo']) ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>
<?php
exit;
