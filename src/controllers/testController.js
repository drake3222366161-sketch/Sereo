const db = require('../config/database');

// OBTENER PREGUNTAS
const obtenerPreguntas = (req, res) => {
  db.query(
    'SELECT id_pregunta, texto, orden FROM preguntas_test WHERE activo = true ORDER BY orden',
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener las preguntas' });
      }
      res.json({ preguntas: results });
    }
  );
};

// GUARDAR EVALUACION
const guardarEvaluacion = (req, res) => {
  const { respuestas } = req.body;
  const id_usuario = req.usuario.id_usuario;

  if (!respuestas || respuestas.length === 0) {
    return res.status(400).json({ error: 'No se recibieron respuestas' });
  }

  // Calcular puntaje total
  const puntaje_total = respuestas.reduce((suma, r) => suma + r.valor, 0);

  // Determinar nivel de estrés
  // 8 preguntas, cada una valor 1-5, máximo 40 puntos
  let nivel_estres;
  if (puntaje_total <= 16) {
    nivel_estres = 'bajo';
  } else if (puntaje_total <= 28) {
    nivel_estres = 'moderado';
  } else {
    nivel_estres = 'alto';
  }

  // Guardar evaluación
  db.query(
    'INSERT INTO evaluaciones (id_usuario, puntaje_total, nivel_estres) VALUES (?, ?, ?)',
    [id_usuario, puntaje_total, nivel_estres],
    (error, result) => {
      if (error) {
        return res.status(500).json({ error: 'Error al guardar la evaluación' });
      }

      const id_evaluacion = result.insertId;

      // Guardar cada respuesta individual
      const valoresRespuestas = respuestas.map(r => [id_evaluacion, r.id_pregunta, r.valor]);

      db.query(
        'INSERT INTO respuestas_evaluacion (id_evaluacion, id_pregunta, valor) VALUES ?',
        [valoresRespuestas],
        (error) => {
          if (error) {
            return res.status(500).json({ error: 'Error al guardar las respuestas' });
          }

          // Obtener recomendaciones según el nivel
          db.query(
            'SELECT titulo, descripcion FROM recomendaciones WHERE nivel_estres = ? AND activo = true',
            [nivel_estres],
            (error, recomendaciones) => {
              if (error) {
                return res.status(500).json({ error: 'Error al obtener recomendaciones' });
              }

              res.status(201).json({
                mensaje: 'Evaluación guardada correctamente',
                resultado: {
                  puntaje_total,
                  nivel_estres,
                  recomendaciones
                }
              });
            }
          );
        }
      );
    }
  );
};

// HISTORIAL DE EVALUACIONES
const historialEvaluaciones = (req, res) => {
  const id_usuario = req.usuario.id_usuario;

  db.query(
    'SELECT id_evaluacion, fecha, puntaje_total, nivel_estres FROM evaluaciones WHERE id_usuario = ? ORDER BY fecha DESC',
    [id_usuario],
    (error, results) => {
      if (error) {
        return res.status(500).json({ error: 'Error al obtener el historial' });
      }
      res.json({ historial: results });
    }
  );
};

module.exports = { obtenerPreguntas, guardarEvaluacion, historialEvaluaciones }; 
