const express = require('express');
const router = express.Router();
const { verDisponibilidad, verPsicologos, agendarCita, misCitas, cancelarCita } = require('../controllers/citasController');
const { verificarToken } = require('../middlewares/authMiddleware');

router.get('/psicologos', verificarToken, verPsicologos);
router.get('/disponibilidad/:id_psicologo', verificarToken, verDisponibilidad);
router.post('/agendar', verificarToken, agendarCita);
router.get('/mis-citas', verificarToken, misCitas);
router.put('/cancelar/:id_cita', verificarToken, cancelarCita);

module.exports = router; 
