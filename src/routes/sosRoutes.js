const express = require('express');
const router = express.Router();
const { enviarSOS, misSolicitudes, todasSolicitudes, actualizarEstado } = require('../controllers/sosController');
const { verificarToken, soloPsicologo } = require('../middlewares/authMiddleware');

router.post('/enviar', verificarToken, enviarSOS);
router.get('/mis-solicitudes', verificarToken, misSolicitudes);
router.get('/todas', verificarToken, soloPsicologo, todasSolicitudes);
router.put('/estado/:id_solicitud', verificarToken, soloPsicologo, actualizarEstado);

module.exports = router; 
