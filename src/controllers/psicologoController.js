const db = require('../config/database');

// VER CITAS DEL PSICOLOGO
const verCitas = (req, res) => {
  const id_usuario = req.usuario.id_usuario;

  db.query(
    `SELECT p.id_psicologo FROM psicologos p WHERE p.id_usuario = ?`,
    [id_usuario],
    (error, results) => {
      if (error || results.length === 0) {
        return res.status(404).json({ error: 'Psicólogo no encontrado' });
      }

      const id_psicologo = results[0].id_psicologo;

      db.query(
        `SELECT c.id_cita, c.fecha, c.hora, c.motivo, c.estado, c.observaciones,
         CASE WHEN u.es_anonimo = true THEN 'Estudiante Anónimo'
         ELSE u.correo END AS estudiante
         FROM citas c
         JOIN usuarios u ON c.id_estudiante = u.id_usuario
         WHERE c.id_psicologo = ?
         ORDER BY
         CASE c.estado
           WHEN 'pendiente' THEN 1
           WHEN 'aprobada' THEN 2
           WHEN 'atendida' THEN 3
           WHEN 'cancelada' THEN 4
           WHEN 'rechazada' THEN 5
         END, c.fecha ASC`,
        [id_psicologo],
        (error, citas) => {
          if (error) {
            return res.status(500).json({ error: 'Error al obtener las citas' });
          }
          res.json({ citas });
        }
      );
    }
  );
};

// APROBAR CITA
const aprobarCita = (req, res) => {
  const { id_cita } = req.params;

  db.query(
    `SELECT id_cita, estado FROM citas WHERE id_cita = ?`,
    [id_cita],
    (error, results) => {
      if (error || results.length === 0) {
        return res.status(404).json({ error: 'Cita no encontrada' });
      }

      if (results[0].estado !== 'pendiente') {
        return res.status(400).json({ error: 'Solo se pueden aprobar citas pendientes' });
      }

      db.query(
        `UPDATE citas SET estado = 'aprobada' WHERE id_cita = ?`,
        [id_cita],
        (error) => {
          if (error) {
            return res.status(500).json({ error: 'Error al aprobar la cita' });
          }
          res.json({ mensaje: 'Cita aprobada correctamente' });
        }
      );
    }
  );
};

// RECHAZAR CITA
const rechazarCita = (req, res) => {
  const { id_cita } = req.params;
  const { observaciones } = req.body;

  db.query(
    `SELECT id_cita, estado FROM citas WHERE id_cita = ?`,
    [id_cita],
    (error, results) => {
      if (error || results.length === 0) {
        return res.status(404).json({ error: 'Cita no encontrada' });
      }

      if (results[0].estado !== 'pendiente') {
        return res.status(400).json({ error: 'Solo se pueden rechazar citas pendientes' });
      }

      db.query(
        `UPDATE citas SET estado = 'rechazada', observaciones = ? WHERE id_cita = ?`,
        [observaciones || null, id_cita],
        (error) => {
          if (error) {
            return res.status(500).json({ error: 'Error al rechazar la cita' });
          }
          res.json({ mensaje: 'Cita rechazada correctamente' });
        }
      );
    }
  );
};

// MARCAR CITA COMO ATENDIDA
const atenderCita = (req, res) => {
  const { id_cita } = req.params;
  const { observaciones } = req.body;

  db.query(
    `UPDATE citas SET estado = 'atendida', observaciones = ? WHERE id_cita = ?`,
    [observaciones || null, id_cita],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al actualizar la cita' });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Cita no encontrada' });
      }
      res.json({ mensaje: 'Cita marcada como atendida' });
    }
  );
};

// REGISTRAR DISPONIBILIDAD
const registrarDisponibilidad = (req, res) => {
  const id_usuario = req.usuario.id_usuario;
  const { dia_semana, hora_inicio, hora_fin } = req.body;

  if (!dia_semana || !hora_inicio || !hora_fin) {
    return res.status(400).json({ error: 'Día, hora inicio y hora fin son obligatorios' });
  }

  db.query(
    `SELECT id_psicologo FROM psicologos WHERE id_usuario = ?`,
    [id_usuario],
    (error, results) => {
      if (error || results.length === 0) {
        return res.status(404).json({ error: 'Psicólogo no encontrado' });
      }

      const id_psicologo = results[0].id_psicologo;

      db.query(
        `INSERT INTO disponibilidad (id_psicologo, dia_semana, hora_inicio, hora_fin) 
         VALUES (?, ?, ?, ?)`,
        [id_psicologo, dia_semana, hora_inicio, hora_fin],
        (error, result) => {
          if (error) {
            return res.status(500).json({ error: 'Error al registrar disponibilidad' });
          }
          res.status(201).json({ mensaje: 'Disponibilidad registrada correctamente' });
        }
      );
    }
  );
};

// VER ESTADISTICAS
const verEstadisticas = (req, res) => {
  const id_usuario = req.usuario.id_usuario;

  db.query(
    `SELECT id_psicologo FROM psicologos WHERE id_usuario = ?`,
    [id_usuario],
    (error, results) => {
      if (error || results.length === 0) {
        return res.status(404).json({ error: 'Psicólogo no encontrado' });
      }

      const id_psicologo = results[0].id_psicologo;

      // Contar citas por estado
      db.query(
        `SELECT estado, COUNT(*) AS total FROM citas 
         WHERE id_psicologo = ? GROUP BY estado`,
        [id_psicologo],
        (error, citas) => {
          if (error) {
            return res.status(500).json({ error: 'Error al obtener estadísticas' });
          }

          // Contar solicitudes SOS
          db.query(
            `SELECT estado, COUNT(*) AS total FROM solicitudes_sos 
             WHERE id_psicologo_asignado = ? GROUP BY estado`,
            [id_psicologo],
            (error, sos) => {
              if (error) {
                return res.status(500).json({ error: 'Error al obtener estadísticas SOS' });
              }

              // Contar evaluaciones por nivel
              db.query(
                `SELECT nivel_estres, COUNT(*) AS total 
                 FROM evaluaciones GROUP BY nivel_estres`,
                (error, evaluaciones) => {
                  if (error) {
                    return res.status(500).json({ error: 'Error al obtener evaluaciones' });
                  }

                  res.json({
                    estadisticas: {
                      citas,
                      solicitudes_sos: sos,
                      evaluaciones
                    }
                  });
                }
              );
            }
          );
        }
      );
    }
  );
};

module.exports = { verCitas, aprobarCita, rechazarCita, atenderCita, registrarDisponibilidad, verEstadisticas }; 
