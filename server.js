// server.js - EarthSweet Main Server
require('dotenv').config();

const express    = require('express');
const cors       = require('cors');
const helmet     = require('helmet');
const morgan     = require('morgan');
const rateLimit  = require('express-rate-limit');
const path       = require('path');
const routes     = require('./routes/index');
const uploadRoutes = require('./routes/upload');

const app  = express();
const PORT = process.env.PORT || 5000;

// ============================================================
// SECURITY & MIDDLEWARE
// ============================================================
app.use(helmet({ contentSecurityPolicy: false }));

// CORS - Allow ALL origins (for local development)
app.use(cors({
  origin: '*',
  methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS'],
  allowedHeaders: ['Content-Type','Authorization'],
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
const orderLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 20,
  message: { success: false, message: 'Too many orders from this IP. Please wait.' },
});

app.use('/api/', limiter);
app.use('/api/orders', orderLimiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging
app.use(morgan('dev'));

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Serve frontend
app.use(express.static(path.join(__dirname, 'public')));

// ============================================================
// API ROUTES
// ============================================================
app.use('/api', routes);
app.use('/api/upload', uploadRoutes);
app.use('/uploads', require('express').static(require('path').join(__dirname, 'uploads')));

// ============================================================
// ERROR HANDLING
// ============================================================
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

app.use((err, req, res, next) => {
  console.error('❌ Error:', err.message);
  res.status(500).json({ success: false, message: 'Internal server error' });
});

// ============================================================
// START SERVER
// ============================================================
app.listen(PORT, () => {
  console.log(`
  ╔══════════════════════════════════════╗
  ║   🌿 EarthSweet Backend Running      ║
  ║   Port: ${PORT}                         ║
  ║   Mode: ${process.env.NODE_ENV || 'development'}                  ║
  ║   API:  http://localhost:${PORT}/api   ║
  ╚══════════════════════════════════════╝
  `);
});

module.exports = app;
