const express = require('express');
const router = express.Router();
const { obtenerPreguntas, guardarEvaluacion, historialEvaluaciones } = require('../controllers/testController');
const { verificarToken } = require('../middlewares/authMiddleware');

router.get('/preguntas', verificarToken, obtenerPreguntas);
router.post('/guardar', verificarToken, guardarEvaluacion);
router.get('/historial', verificarToken, historialEvaluaciones);

module.exports = router; 
