const db = require('../config/database');

// VER TODOS LOS RECURSOS
const verRecursos = (req, res) => {
  db.query(
    `SELECT r.id_recurso, r.nombre, r.ubicacion, r.horario, r.correo_contacto,
     GROUP_CONCAT(CONCAT(t.numero, ' - ', t.descripcion) SEPARATOR ' | ') AS telefonos
     FROM recursos_institucionales r
     LEFT JOIN telefonos_recursos t ON r.id_recurso = t.id_recurso
     WHERE r.activo = true
     GROUP BY r.id_recurso`,
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener recursos' });
      }
      res.json({ recursos: results });
    }
  );
};

// VER UN RECURSO ESPECIFICO
const verRecurso = (req, res) => {
  const { id_recurso } = req.params;

  db.query(
    `SELECT r.id_recurso, r.nombre, r.ubicacion, r.horario, r.correo_contacto
     FROM recursos_institucionales r
     WHERE r.id_recurso = ? AND r.activo = true`,
    [id_recurso],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener el recurso' });
      }
      if (results.length === 0) {
        return res.status(404).json({ error: 'Recurso no encontrado' });
      }

      const recurso = results[0];

      db.query(
        `SELECT numero, descripcion FROM telefonos_recursos WHERE id_recurso = ?`,
        [id_recurso],
        (error, telefonos) => {
          if (error) {
            return res.status(500).json({ error: 'Error al obtener teléfonos' });
          }
          res.json({ recurso: { ...recurso, telefonos } });
        }
      );
    }
  );
};

// ACTUALIZAR RECURSO (admin)
const actualizarRecurso = (req, res) => {
  const { id_recurso } = req.params;
  const { nombre, ubicacion, horario, correo_contacto } = req.body;

  db.query(
    `UPDATE recursos_institucionales 
     SET nombre = ?, ubicacion = ?, horario = ?, correo_contacto = ?
     WHERE id_recurso = ?`,
    [nombre, ubicacion, horario, correo_contacto, id_recurso],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al actualizar el recurso' });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Recurso no encontrado' });
      }
      res.json({ mensaje: 'Recurso actualizado correctamente' });
    }
  );
};

module.exports = { verRecursos, verRecurso, actualizarRecurso }; 
