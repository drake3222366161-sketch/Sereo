 const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
require('dotenv').config();

// REGISTRO
const registro = (req, res) => {
  const { correo, contrasena } = req.body;

  // Validar que el correo sea institucional
  if (!correo.endsWith('@ucundinamarca.edu.co')) {
    return res.status(400).json({ 
      error: 'Solo se permiten correos institucionales (@ucundinamarca.edu.co)' 
    });
  }

  // Validar que la contraseña tenga mínimo 6 caracteres
  if (contrasena.length < 6) {
    return res.status(400).json({ 
      error: 'La contraseña debe tener mínimo 6 caracteres' 
    });
  }

  // Verificar si el correo ya existe
  db.query('SELECT id_usuario FROM usuarios WHERE correo = ?', [correo], (error, results) => {
    if (error) {
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    if (results.length > 0) {
      return res.status(400).json({ error: 'Este correo ya está registrado' });
    }

    // Encriptar contraseña
    const contrasenaEncriptada = bcrypt.hashSync(contrasena, 10);

    // Guardar usuario
    db.query(
      'INSERT INTO usuarios (correo, contrasena, rol) VALUES (?, ?, ?)',
      [correo, contrasenaEncriptada, 'estudiante'],
      (error, results) => {
        if (error) {
          return res.status(500).json({ error: 'Error al crear el usuario' });
        }

        res.status(201).json({ 
          mensaje: 'Usuario registrado correctamente',
          id_usuario: results.insertId
        });
      }
    );
  });
};

// LOGIN
const login = (req, res) => {
  const { correo, contrasena } = req.body;

  // Buscar usuario
  db.query('SELECT * FROM usuarios WHERE correo = ?', [correo], (error, results) => {
    if (error) {
      return res.status(500).json({ error: 'Error en el servidor' });
    }

    if (results.length === 0) {
      return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
    }

    const usuario = results[0];

    // Verificar si está activo
    if (!usuario.activo) {
      return res.status(401).json({ error: 'Esta cuenta está desactivada' });
    }

    // Verificar contraseña
    const contrasenaValida = bcrypt.compareSync(contrasena, usuario.contrasena);
    if (!contrasenaValida) {
      return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
    }

    // Generar token JWT
    const token = jwt.sign(
      { 
        id_usuario: usuario.id_usuario, 
        correo: usuario.correo,
        rol: usuario.rol 
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      mensaje: 'Login exitoso',
      token,
      usuario: {
        id_usuario: usuario.id_usuario,
        correo: usuario.correo,
        rol: usuario.rol
      }
    });
  });
};

module.exports = { registro, login };
