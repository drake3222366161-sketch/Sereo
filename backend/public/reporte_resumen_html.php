<?php

require_once __DIR__ . '/../lib/audit.php';

// 1. Incluir el autoload subiendo un nivel desde public/ a backend/vendor/
require_once __DIR__ . '/../vendor/autoload.php';

use Dompdf\Dompdf;
use Dompdf\Options;

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
registrarLog($pdo, 'REPORTE_RESUMEN_PDF_GENERADO', 'reportes', $_GET['usuario_id'] ?? null, ['formato' => 'pdf']);

// 2. MÉTRICAS GENERALES
$totalSos = $pdo->query("SELECT COUNT(*) AS t FROM solicitudes_sos")->fetch()['t'];
$sosPendientes = $pdo->query("SELECT COUNT(*) AS t FROM solicitudes_sos WHERE estado='pendiente'")->fetch()['t'];
$totalCitas = $pdo->query("SELECT COUNT(*) AS t FROM citas WHERE estado != 'cancelada'")->fetch()['t'];
$totalAutoevaluaciones = $pdo->query("SELECT COUNT(*) AS t FROM autoevaluaciones")->fetch()['t'];
$totalEstudiantes = $pdo->query("SELECT COUNT(*) AS t FROM usuarios WHERE rol='estudiante'")->fetch()['t'];

// 3. INDICADORES POR PROGRAMA
$stmt = $pdo->query(
    "SELECT
        u.programa_academico,
        COUNT(DISTINCT u.id) AS total_estudiantes,
        (SELECT COUNT(*) FROM solicitudes_sos s JOIN usuarios ue ON ue.id = s.estudiante_id
            WHERE ue.programa_academico = u.programa_academico) AS total_sos,
        (SELECT COUNT(*) FROM citas c JOIN usuarios ue ON ue.id = c.estudiante_id
            WHERE ue.programa_academico = u.programa_academico AND c.estado != 'cancelada') AS total_citas,
        (SELECT ROUND(AVG(a.puntaje_total), 1) FROM autoevaluaciones a JOIN usuarios ue ON ue.id = a.estudiante_id
            WHERE ue.programa_academico = u.programa_academico) AS promedio_phq9
     FROM usuarios u
     WHERE u.rol = 'estudiante' AND u.programa_academico IS NOT NULL
     GROUP BY u.programa_academico
     ORDER BY total_sos DESC"
);
$programas = $stmt->fetchAll(PDO::FETCH_ASSOC);

// 4. BARRIDO DETALLADO DE DATOS (Lo que solicita el profesor)
$stmtSos = $pdo->query(
    "SELECT s.id, u.nombre_completo AS estudiante, u.programa_academico, s.estado, s.fecha_solicitud
     FROM solicitudes_sos s
     JOIN usuarios u ON u.id = s.estudiante_id
     ORDER BY s.fecha_solicitud DESC LIMIT 50"
);
$detalleSos = $stmtSos->fetchAll(PDO::FETCH_ASSOC);

$fechaHoy = date('d/m/Y H:i');

// 5. CONSTRUIR EL HTML DEL PDF
ob_start();
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<style>
    body { font-family: Helvetica, Arial, sans-serif; color: #222; font-size: 11px; margin: 15px; }
    h1 { color: #0F6E56; font-size: 20px; margin-bottom: 2px; }
    .subtitulo { color: #555; font-size: 10px; margin-bottom: 20px; border-bottom: 2px solid #0F6E56; padding-bottom: 5px; }
    
    .metricas-table { width: 100%; border-collapse: separate; border-spacing: 8px; margin-bottom: 15px; }
    .tarjeta { background: #F4F9F7; border: 1px solid #B0D8CE; padding: 10px; text-align: center; border-radius: 4px; }
    .valor { font-size: 18px; font-weight: bold; color: #0F6E56; }
    .etiqueta { font-size: 9px; color: #444; }

    table.data { width: 100%; border-collapse: collapse; margin-top: 10px; margin-bottom: 20px; }
    table.data th, table.data td { border: 1px solid #CCCCCC; padding: 6px 8px; font-size: 10px; text-align: left; }
    table.data th { background-color: #0F6E56; color: #FFFFFF; font-weight: bold; }
    table.data tr:nth-child(even) { background-color: #F9F9F9; }
    
    .badge { font-weight: bold; padding: 2px 5px; border-radius: 3px; font-size: 9px; }
    .badge-pendiente { background-color: #FFE6E6; color: #C00000; }
    .badge-atendido { background-color: #E2F0D9; color: #385723; }
</style>
</head>
<body>

<h1>SEREO — Reporte General de Gestión</h1>
<div class="subtitulo">Sistema de Bienestar Universitario — Emisión: <?= $fechaHoy ?></div>

<!-- Tarjetas de Resumen -->
<table class="metricas-table">
    <tr>
        <td class="tarjeta"><div class="valor"><?= $totalEstudiantes ?></div><div class="etiqueta">Estudiantes</div></td>
        <td class="tarjeta"><div class="valor"><?= $totalSos ?></div><div class="etiqueta">Total SOS</div></td>
        <td class="tarjeta"><div class="valor"><?= $sosPendientes ?></div><div class="etiqueta">SOS Pendientes</div></td>
        <td class="tarjeta"><div class="valor"><?= $totalCitas ?></div><div class="etiqueta">Citas Realizadas</div></td>
        <td class="tarjeta"><div class="valor"><?= $totalAutoevaluaciones ?></div><div class="etiqueta">PHQ-9 Completados</div></td>
    </tr>
</table>

<h3>1. Indicadores por Programa Académico</h3>
<table class="data">
    <thead>
        <tr>
            <th>Programa Académico</th>
            <th style="text-align: center;">Estudiantes</th>
            <th style="text-align: center;">Solicitudes SOS</th>
            <th style="text-align: center;">Citas</th>
            <th style="text-align: center;">Promedio PHQ-9</th>
        </tr>
    </thead>
    <tbody>
        <?php foreach ($programas as $p): ?>
        <tr>
            <td><?= htmlspecialchars($p['programa_academico']) ?></td>
            <td style="text-align: center;"><?= $p['total_estudiantes'] ?></td>
            <td style="text-align: center;"><?= $p['total_sos'] ?></td>
            <td style="text-align: center;"><?= $p['total_citas'] ?></td>
            <td style="text-align: center;"><?= $p['promedio_phq9'] ?? 'N/A' ?></td>
        </tr>
        <?php endforeach; ?>
    </tbody>
</table>

<h3>2. Barrido Detallado de Solicitudes SOS</h3>
<table class="data">
    <thead>
        <tr>
            <th style="width: 35px;">ID</th>
            <th>Estudiante</th>
            <th>Programa Académico</th>
            <th style="width: 80px; text-align: center;">Estado</th>
            <th style="width: 120px; text-align: center;">Fecha Solicitud</th>
        </tr>
    </thead>
    <tbody>
        <?php foreach ($detalleSos as $sos): ?>
        <tr>
            <td><?= $sos['id'] ?></td>
            <td><?= htmlspecialchars($sos['estudiante']) ?></td>
            <td><?= htmlspecialchars($sos['programa_academico']) ?></td>
            <td style="text-align: center;">
                <span class="badge <?= $sos['estado'] == 'pendiente' ? 'badge-pendiente' : 'badge-atendido' ?>">
                    <?= strtoupper(htmlspecialchars($sos['estado'])) ?>
                </span>
            </td>
            <td style="text-align: center;"><?= htmlspecialchars($sos['fecha_solicitud']) ?></td>
        </tr>
        <?php endforeach; ?>
    </tbody>
</table>

<p style="font-size: 8px; color: #888; margin-top: 15px;">
    Documento generado automáticamente por el sistema SEREO.
</p>

</body>
</html>
<?php
$html = ob_get_clean();

// 6. GENERACIÓN DEL PDF CON DOMPDF
$options = new Options();
$options->set('isHtml5ParserEnabled', true);
$options->set('defaultFont', 'Helvetica');

$dompdf = new Dompdf($options);
$dompdf->loadHtml($html);
$dompdf->setPaper('A4', 'portrait');
$dompdf->render();

// Forzar descarga del PDF directamente en el navegador
$dompdf->stream("sereo_reporte_general_" . date('Y-m-d') . ".pdf", ["Attachment" => true]);
exit;
