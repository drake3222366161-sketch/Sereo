const express = require('express');
const router = express.Router();
const { verRecursos, verRecurso, actualizarRecurso } = require('../controllers/recursosController');
const { verificarToken, soloAdmin } = require('../middlewares/authMiddleware');

router.get('/', verificarToken, verRecursos);
router.get('/:id_recurso', verificarToken, verRecurso);
router.put('/:id_recurso/actualizar', verificarToken, soloAdmin, actualizarRecurso);

module.exports = router; 
