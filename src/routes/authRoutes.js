const express = require('express');
const router = express.Router();
const { registro, login } = require('../controllers/authController');
const { verificarToken } = require('../middlewares/authMiddleware');

router.post('/registro', registro);
router.post('/login', login);

// Ruta protegida de prueba
router.get('/perfil', verificarToken, (req, res) => {
  res.json({ 
    mensaje: 'Token válido',
    usuario: req.usuario 
  });
});

module.exports = router;