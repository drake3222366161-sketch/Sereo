const db = require('../config/database');

// ENVIAR SOLICITUD SOS
const enviarSOS = (req, res) => {
  const { mensaje } = req.body;
  const id_usuario = req.usuario.id_usuario;

  if (!mensaje || mensaje.trim() === '') {
    return res.status(400).json({ error: 'El mensaje no puede estar vacío' });
  }

  db.query(
    'INSERT INTO solicitudes_sos (id_usuario, mensaje) VALUES (?, ?)',
    [id_usuario, mensaje],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al enviar la solicitud' });
      }

      res.status(201).json({
        mensaje: 'Solicitud de ayuda enviada correctamente',
        id_solicitud: result.insertId,
        texto: 'Un psicólogo se pondrá en contacto contigo pronto'
      });
    }
  );
};

// VER MIS SOLICITUDES SOS (estudiante)
const misSolicitudes = (req, res) => {
  const id_usuario = req.usuario.id_usuario;

  db.query(
    `SELECT id_solicitud, mensaje, estado, fecha_envio 
     FROM solicitudes_sos 
     WHERE id_usuario = ? 
     ORDER BY fecha_envio DESC`,
    [id_usuario],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener las solicitudes' });
      }
      res.json({ solicitudes: results });
    }
  );
};

// VER TODAS LAS SOLICITUDES SOS (psicólogo)
const todasSolicitudes = (req, res) => {
  db.query(
    `SELECT s.id_solicitud, s.mensaje, s.estado, s.fecha_envio,
     CASE WHEN u.es_anonimo = true THEN 'Estudiante Anónimo' 
     ELSE u.correo END AS estudiante
     FROM solicitudes_sos s
     JOIN usuarios u ON s.id_usuario = u.id_usuario
     ORDER BY 
     CASE s.estado 
       WHEN 'pendiente' THEN 1 
       WHEN 'en_proceso' THEN 2 
       WHEN 'atendida' THEN 3 
     END, s.fecha_envio ASC`,
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener las solicitudes' });
      }
      res.json({ solicitudes: results });
    }
  );
};

// ACTUALIZAR ESTADO SOS (psicólogo)
const actualizarEstado = (req, res) => {
  const { id_solicitud } = req.params;
  const { estado } = req.body;

  const estadosValidos = ['en_proceso', 'atendida'];
  if (!estadosValidos.includes(estado)) {
    return res.status(400).json({ error: 'Estado no válido' });
  }

  db.query(
    'UPDATE solicitudes_sos SET estado = ?, id_psicologo_asignado = ? WHERE id_solicitud = ?',
    [estado, req.usuario.id_usuario, id_solicitud],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al actualizar el estado' });
      }

      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Solicitud no encontrada' });
      }

      res.json({ mensaje: `Solicitud marcada como ${estado}` });
    }
  );
};

module.exports = { enviarSOS, misSolicitudes, todasSolicitudes, actualizarEstado }; 
