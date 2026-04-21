// routes/upload.js - Product Image Upload
const express  = require('express');
const multer   = require('multer');
const path     = require('path');
const fs       = require('fs');
const db       = require('../database/db');

const router = express.Router();

// Storage config
const storage = multer.diskStorage({
  destination: function(req, file, cb) {
    const dir = path.join(__dirname, '../uploads/products');
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: function(req, file, cb) {
    const ext  = path.extname(file.originalname).toLowerCase();
    const name = 'product-' + Date.now() + ext;
    cb(null, name);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max
  fileFilter: function(req, file, cb) {
    const allowed = ['.jpg', '.jpeg', '.png', '.webp', '.jfif'];
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowed.includes(ext)) cb(null, true);
    else cb(new Error('Only JPG, PNG, WEBP, JFIF allowed'));
  }
});

// POST /api/upload/product/:id
router.post('/product/:id', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });

    const imageUrl = '/uploads/products/' + req.file.filename;

    // Delete old image if exists
    const [rows] = await db.execute('SELECT image_url FROM products WHERE id=?', [req.params.id]);
    if (rows.length && rows[0].image_url) {
      const oldPath = path.join(__dirname, '..', rows[0].image_url);
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
    }

    // Update DB
    await db.execute('UPDATE products SET image_url=? WHERE id=?', [imageUrl, req.params.id]);

    res.json({ success: true, message: 'Image uploaded!', image_url: imageUrl });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// DELETE /api/upload/product/:id
router.delete('/product/:id', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT image_url FROM products WHERE id=?', [req.params.id]);
    if (rows.length && rows[0].image_url) {
      const oldPath = path.join(__dirname, '..', rows[0].image_url);
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
      await db.execute('UPDATE products SET image_url=NULL WHERE id=?', [req.params.id]);
    }
    res.json({ success: true, message: 'Image removed' });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;