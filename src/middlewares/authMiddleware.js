const jwt = require('jsonwebtoken');
require('dotenv').config();

const verificarToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Acceso denegado, token requerido' });
  }

  try {
    const datos = jwt.verify(token, process.env.JWT_SECRET);
    req.usuario = datos;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
};

const soloAdmin = (req, res, next) => {
  if (req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'Acceso denegado, se requiere rol admin' });
  }
  next();
};

const soloPsicologo = (req, res, next) => {
  if (req.usuario.rol !== 'psicologo' && req.usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'Acceso denegado, se requiere rol psicólogo' });
  }
  next();
};

module.exports = { verificarToken, soloAdmin, soloPsicologo }; 
