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
registrarLog($pdo, 'REPORTE_ESTADISTICAS_EXPORTADO', 'reportes', $_GET['usuario_id'] ?? null, ['formato' => 'xls']);

// Consulta de indicadores clave por programa académico
$stmt = $pdo->query(
    "SELECT
        u.programa_academico,
        COUNT(DISTINCT u.id) AS total_estudiantes,
        (SELECT COUNT(*) FROM solicitudes_sos s
            JOIN usuarios ue ON ue.id = s.estudiante_id
            WHERE ue.programa_academico = u.programa_academico) AS total_sos,
        (SELECT COUNT(*) FROM citas c
            JOIN usuarios ue ON ue.id = c.estudiante_id
            WHERE ue.programa_academico = u.programa_academico
              AND c.estado != 'cancelada') AS total_citas,
        (SELECT COUNT(*) FROM citas c
            JOIN usuarios ue ON ue.id = c.estudiante_id
            WHERE ue.programa_academico = u.programa_academico
              AND c.estado = 'cancelada') AS citas_canceladas,
        (SELECT COUNT(*) FROM autoevaluaciones a
            JOIN usuarios ue ON ue.id = a.estudiante_id
            WHERE ue.programa_academico = u.programa_academico) AS total_autoevaluaciones,
        (SELECT ROUND(AVG(a.puntaje_total), 1) FROM autoevaluaciones a
            JOIN usuarios ue ON ue.id = a.estudiante_id
            WHERE ue.programa_academico = u.programa_academico) AS promedio_puntaje_phq9,
        (SELECT COUNT(*) FROM autoevaluaciones a
            JOIN usuarios ue ON ue.id = a.estudiante_id
            WHERE ue.programa_academico = u.programa_academico
              AND a.clasificacion IN ('Moderado', 'Moderadamente severo', 'Severo')
        ) AS autoevaluaciones_moderado_o_mas
     FROM usuarios u
     WHERE u.rol = 'estudiante' AND u.programa_academico IS NOT NULL
     GROUP BY u.programa_academico
     ORDER BY total_sos DESC, total_citas DESC"
);
$filas = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Configuración de cabeceras para Excel (.xls)
header('Content-Type: application/vnd.ms-excel; charset=utf-8');
header('Content-Disposition: attachment; filename="sereo_estadisticas_por_programa_' . date('Y-m-d') . '.xls"');
header('Pragma: no-cache');
header('Expires: 0');

// BOM UTF-8 para garantizar tildes y eñes
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
        .txt-right { text-align: right; }
        
        /* Semáforo de riesgo para PHQ-9 y Porcentaje */
        .riesgo-bajo { background-color: #E2F0D9; color: #385723; font-weight: bold; text-align: center; }
        .riesgo-medio { background-color: #FFF2CC; color: #B25900; font-weight: bold; text-align: center; }
        .riesgo-alto { background-color: #FCE4D6; color: #C65911; font-weight: bold; text-align: center; }
        
        /* Resaltado especial para casos SOS */
        .sos-alerta { background-color: #F8CBAD; color: #C00000; font-weight: bold; text-align: center; }
    </style>
</head>
<body>
    <table border="1">
        <thead>
            <tr>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 220px;">Programa académico</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 110px;">Total estudiantes</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 110px;">Solicitudes SOS</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 110px;">Citas realizadas</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 110px;">Citas canceladas</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 130px;">Autoevaluaciones realizadas</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 130px;">Puntaje PHQ-9 promedio</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 150px;">Autoevaluaciones en nivel Moderado o más</th>
                <th bgcolor="#1F4E79" style="background-color: #1F4E79; color: #FFFFFF; font-weight: bold; text-align: center; vertical-align: middle; border: 1px solid #1B365D; height: 38px; width: 140px;">% con nivel Moderado o más</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($filas as $f): ?>
                <?php 
                    $totalAuto = (int)$f['total_autoevaluaciones'];
                    $moderadoMas = (int)$f['autoevaluaciones_moderado_o_mas'];
                    $porcentajeVal = $totalAuto > 0 ? round(($moderadoMas / $totalAuto) * 100, 1) : 0;
                    $promedioPhq9 = $f['promedio_puntaje_phq9'] !== null ? (float)$f['promedio_puntaje_phq9'] : null;

                    // Classificadores de color para el promedio PHQ-9
                    $clasePhq9 = 'txt-center';
                    if ($promedioPhq9 !== null) {
                        if ($promedioPhq9 >= 10.0) {
                            $clasePhq9 = 'riesgo-alto';   // Severo/Moderado alto
                        } elseif ($promedioPhq9 >= 5.0) {
                            $clasePhq9 = 'riesgo-medio';  // Leve/Moderado
                        } else {
                            $clasePhq9 = 'riesgo-bajo';   // Mínimo
                        }
                    }

                    // Clasificador de color para el Porcentaje de riesgo
                    $clasePorcentaje = 'txt-center';
                    if ($totalAuto > 0) {
                        if ($porcentajeVal >= 40.0) {
                            $clasePorcentaje = 'riesgo-alto';
                        } elseif ($porcentajeVal >= 20.0) {
                            $clasePorcentaje = 'riesgo-medio';
                        } else {
                            $clasePorcentaje = 'riesgo-bajo';
                        }
                    }

                    // Destacar en rojo si tiene Solicitudes SOS
                    $claseSos = ((int)$f['total_sos'] > 0) ? 'sos-alerta' : 'txt-center';
                ?>
                <tr>
                    <td class="txt-left"><?= htmlspecialchars($f['programa_academico']) ?></td>
                    <td class="txt-center"><?= htmlspecialchars($f['total_estudiantes']) ?></td>
                    <td class="<?= $claseSos ?>"><?= htmlspecialchars($f['total_sos']) ?></td>
                    <td class="txt-center"><?= htmlspecialchars($f['total_citas']) ?></td>
                    <td class="txt-center"><?= htmlspecialchars($f['citas_canceladas']) ?></td>
                    <td class="txt-center"><?= htmlspecialchars($f['total_autoevaluaciones']) ?></td>
                    <td class="<?= $clasePhq9 ?>"><?= $promedioPhq9 !== null ? number_format($promedioPhq9, 1) : 'N/A' ?></td>
                    <td class="txt-center"><?= htmlspecialchars($f['autoevaluaciones_moderado_o_mas']) ?></td>
                    <td class="<?= $clasePorcentaje ?>"><?= $totalAuto > 0 ? $porcentajeVal . '%' : '0%' ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</body>
</html>
<?php
exit;
