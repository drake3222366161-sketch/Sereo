const express = require('express');
const router = express.Router();
const { verPsicologos, crearPsicologo, desactivarCuenta, activarCuenta, verPreguntas, agregarPregunta, desactivarPregunta, verReporteGlobal } = require('../controllers/adminController');
const { verificarToken, soloAdmin } = require('../middlewares/authMiddleware');

router.get('/psicologos', verificarToken, soloAdmin, verPsicologos);
router.post('/psicologos/crear', verificarToken, soloAdmin, crearPsicologo);
router.put('/usuarios/:id_usuario/desactivar', verificarToken, soloAdmin, desactivarCuenta);
router.put('/usuarios/:id_usuario/activar', verificarToken, soloAdmin, activarCuenta);
router.get('/preguntas', verificarToken, soloAdmin, verPreguntas);
router.post('/preguntas/agregar', verificarToken, soloAdmin, agregarPregunta);
router.put('/preguntas/:id_pregunta/desactivar', verificarToken, soloAdmin, desactivarPregunta);
router.get('/reporte', verificarToken, soloAdmin, verReporteGlobal);

module.exports = router; 
