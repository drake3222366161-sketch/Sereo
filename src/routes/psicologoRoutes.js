const express = require('express');
const router = express.Router();
const { verCitas, aprobarCita, rechazarCita, atenderCita, registrarDisponibilidad, verEstadisticas } = require('../controllers/psicologoController');
const { verificarToken, soloPsicologo } = require('../middlewares/authMiddleware');

router.get('/citas', verificarToken, soloPsicologo, verCitas);
router.put('/citas/:id_cita/aprobar', verificarToken, soloPsicologo, aprobarCita);
router.put('/citas/:id_cita/rechazar', verificarToken, soloPsicologo, rechazarCita);
router.put('/citas/:id_cita/atender', verificarToken, soloPsicologo, atenderCita);
router.post('/disponibilidad', verificarToken, soloPsicologo, registrarDisponibilidad);
router.get('/estadisticas', verificarToken, soloPsicologo, verEstadisticas);

module.exports = router; 
