const db = require('../config/database');
const bcrypt = require('bcryptjs');

// VER TODOS LOS PSICOLOGOS
const verPsicologos = (req, res) => {
  db.query(
    `SELECT u.id_usuario, u.correo, u.activo, 
     p.nombre_completo, p.especialidad, p.ubicacion_consultorio
     FROM usuarios u
     JOIN psicologos p ON u.id_usuario = p.id_usuario
     WHERE u.rol = 'psicologo'`,
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener psicólogos' });
      }
      res.json({ psicologos: results });
    }
  );
};

// CREAR CUENTA DE PSICOLOGO
const crearPsicologo = (req, res) => {
  const { correo, contrasena, nombre_completo, especialidad, ubicacion_consultorio } = req.body;

  if (!correo || !contrasena || !nombre_completo) {
    return res.status(400).json({ error: 'Correo, contraseña y nombre son obligatorios' });
  }

  const contrasenaEncriptada = bcrypt.hashSync(contrasena, 10);

  db.query(
    `INSERT INTO usuarios (correo, contrasena, rol) VALUES (?, ?, 'psicologo')`,
    [correo, contrasenaEncriptada],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al crear el usuario' });
      }

      const id_usuario = result.insertId;

      db.query(
        `INSERT INTO psicologos (id_usuario, nombre_completo, especialidad, ubicacion_consultorio) 
         VALUES (?, ?, ?, ?)`,
        [id_usuario, nombre_completo, especialidad || null, ubicacion_consultorio || null],
        (error) => {
          if (error) {
            return res.status(500).json({ error: 'Error al crear el perfil del psicólogo' });
          }
          res.status(201).json({ mensaje: 'Psicólogo creado correctamente' });
        }
      );
    }
  );
};

// DESACTIVAR CUENTA
const desactivarCuenta = (req, res) => {
  const { id_usuario } = req.params;

  db.query(
    `UPDATE usuarios SET activo = false WHERE id_usuario = ?`,
    [id_usuario],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al desactivar la cuenta' });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }
      res.json({ mensaje: 'Cuenta desactivada correctamente' });
    }
  );
};

// ACTIVAR CUENTA
const activarCuenta = (req, res) => {
  const { id_usuario } = req.params;

  db.query(
    `UPDATE usuarios SET activo = true WHERE id_usuario = ?`,
    [id_usuario],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al activar la cuenta' });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Usuario no encontrado' });
      }
      res.json({ mensaje: 'Cuenta activada correctamente' });
    }
  );
};

// VER PREGUNTAS DEL TEST
const verPreguntas = (req, res) => {
  db.query(
    `SELECT id_pregunta, texto, orden, activo 
     FROM preguntas_test ORDER BY orden`,
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener preguntas' });
      }
      res.json({ preguntas: results });
    }
  );
};

// AGREGAR PREGUNTA
const agregarPregunta = (req, res) => {
  const { texto, orden } = req.body;

  if (!texto || !orden) {
    return res.status(400).json({ error: 'Texto y orden son obligatorios' });
  }

  db.query(
    `INSERT INTO preguntas_test (texto, orden) VALUES (?, ?)`,
    [texto, orden],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al agregar la pregunta' });
      }
      res.status(201).json({ mensaje: 'Pregunta agregada correctamente' });
    }
  );
};

// DESACTIVAR PREGUNTA
const desactivarPregunta = (req, res) => {
  const { id_pregunta } = req.params;

  db.query(
    `UPDATE preguntas_test SET activo = false WHERE id_pregunta = ?`,
    [id_pregunta],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al desactivar la pregunta' });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: 'Pregunta no encontrada' });
      }
      res.json({ mensaje: 'Pregunta desactivada correctamente' });
    }
  );
};

// VER REPORTE GLOBAL
const verReporteGlobal = (req, res) => {
  db.query(`SELECT COUNT(*) AS total FROM usuarios WHERE rol = 'estudiante'`, (error, estudiantes) => {
    if (error) return res.status(500).json({ error: 'Error al obtener reporte' });

    db.query(`SELECT nivel_estres, COUNT(*) AS total FROM evaluaciones GROUP BY nivel_estres`, (error, evaluaciones) => {
      if (error) return res.status(500).json({ error: 'Error al obtener reporte' });

      db.query(`SELECT estado, COUNT(*) AS total FROM citas GROUP BY estado`, (error, citas) => {
        if (error) return res.status(500).json({ error: 'Error al obtener reporte' });

        db.query(`SELECT estado, COUNT(*) AS total FROM solicitudes_sos GROUP BY estado`, (error, sos) => {
          if (error) return res.status(500).json({ error: 'Error al obtener reporte' });

          res.json({
            reporte: {
              total_estudiantes: estudiantes[0].total,
              evaluaciones,
              citas,
              solicitudes_sos: sos
            }
          });
        });
      });
    });
  });
};

module.exports = { verPsicologos, crearPsicologo, desactivarCuenta, activarCuenta, verPreguntas, agregarPregunta, desactivarPregunta, verReporteGlobal }; 
