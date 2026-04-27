const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const testRoutes = require('./routes/testRoutes');
const citasRoutes = require('./routes/citasRoutes');
const sosRoutes = require('./routes/sosRoutes');
const psicologoRoutes = require('./routes/psicologoRoutes');
const adminRoutes = require('./routes/adminRoutes');
const recursosRoutes = require('./routes/recursosRoutes');

const app = express();

app.use(cors());
app.use(express.json());

// Rutas
app.use('/auth', authRoutes);
app.use('/test', testRoutes);
app.use('/citas', citasRoutes);
app.use('/sos', sosRoutes);
app.use('/psicologo', psicologoRoutes);
app.use('/admin', adminRoutes);
app.use('/recursos', recursosRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ mensaje: 'Servidor Sereo funcionando correctamente' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});