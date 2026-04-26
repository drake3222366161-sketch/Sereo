const db = require('../config/database');

// VER DISPONIBILIDAD DE UN PSICOLOGO
const verDisponibilidad = (req, res) => {
  const { id_psicologo } = req.params;

  db.query(
    'SELECT dia_semana, hora_inicio, hora_fin FROM disponibilidad WHERE id_psicologo = ? AND activo = true',
    [id_psicologo],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener disponibilidad' });
      }
      res.json({ disponibilidad: results });
    }
  );
};

// VER LISTA DE PSICOLOGOS
const verPsicologos = (req, res) => {
  db.query(
    `SELECT p.id_psicologo, p.nombre_completo, p.especialidad, 
     p.ubicacion_consultorio, u.correo 
     FROM psicologos p 
     JOIN usuarios u ON p.id_usuario = u.id_usuario 
     WHERE u.activo = true`,
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener psicólogos' });
      }
      res.json({ psicologos: results });
    }
  );
};

// AGENDAR CITA
const agendarCita = (req, res) => {
  const { id_psicologo, fecha, hora, motivo } = req.body;
  const id_estudiante = req.usuario.id_usuario;

  if (!id_psicologo || !fecha || !hora) {
    return res.status(400).json({ error: 'Psicólogo, fecha y hora son obligatorios' });
  }

  // Verificar que no exista ya una cita en esa fecha y hora con ese psicólogo
  db.query(
    `SELECT id_cita FROM citas 
     WHERE id_psicologo = ? AND fecha = ? AND hora = ? 
     AND estado NOT IN ('rechazada', 'cancelada')`,
    [id_psicologo, fecha, hora],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al verificar disponibilidad' });
      }

      if (results.length > 0) {
        return res.status(400).json({ error: 'Ese horario ya está ocupado' });
      }

      // Crear la cita
      db.query(
        'INSERT INTO citas (id_estudiante, id_psicologo, fecha, hora, motivo) VALUES (?, ?, ?, ?, ?)',
        [id_estudiante, id_psicologo, fecha, hora, motivo],
        (error, result) => {
          if (error) {
            return res.status(500).json({ error: 'Error al agendar la cita' });
          }

          res.status(201).json({
            mensaje: 'Cita agendada correctamente, espera la confirmación del psicólogo',
            id_cita: result.insertId
          });
        }
      );
    }
  );
};

// VER MIS CITAS (estudiante)
const misCitas = (req, res) => {
  const id_estudiante = req.usuario.id_usuario;

  db.query(
    `SELECT c.id_cita, c.fecha, c.hora, c.motivo, c.estado,
     p.nombre_completo AS psicologo, p.ubicacion_consultorio
     FROM citas c
     JOIN psicologos p ON c.id_psicologo = p.id_psicologo
     WHERE c.id_estudiante = ?
     ORDER BY c.fecha DESC`,
    [id_estudiante],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener las citas' });
      }
      res.json({ citas: results });
    }
  );
};

// CANCELAR CITA (estudiante)
const cancelarCita = (req, res) => {
  const { id_cita } = req.params;
  const id_estudiante = req.usuario.id_usuario;

  // Verificar que la cita pertenece al estudiante y está pendiente
  db.query(
    'SELECT id_cita, estado FROM citas WHERE id_cita = ? AND id_estudiante = ?',
    [id_cita, id_estudiante],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al buscar la cita' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'Cita no encontrada' });
      }

      if (results[0].estado !== 'pendiente' && results[0].estado !== 'aprobada') {
        return res.status(400).json({ error: 'Esta cita no puede cancelarse' });
      }

      db.query(
        'UPDATE citas SET estado = ? WHERE id_cita = ?',
        ['cancelada', id_cita],
        (error) => {
          if (error) {
            return res.status(500).json({ error: 'Error al cancelar la cita' });
          }
          res.json({ mensaje: 'Cita cancelada correctamente' });
        }
      );
    }
  );
};

module.exports = { verDisponibilidad, verPsicologos, agendarCita, misCitas, cancelarCita }; 
