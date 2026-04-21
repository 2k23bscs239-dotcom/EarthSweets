// routes/upload.js - Product Image Upload (Cloudinary)
const express    = require('express');
const multer     = require('multer');
const cloudinary = require('cloudinary').v2;
const db         = require('../database/db');

const router = express.Router();

// Cloudinary config — Railway env vars se aata hai
cloudinary.config({
  cloud_name:  process.env.CLOUDINARY_CLOUD_NAME,
  api_key:     process.env.CLOUDINARY_API_KEY,
  api_secret:  process.env.CLOUDINARY_API_SECRET,
});

// Multer — memory mein rakho, disk pe nahi
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: function(req, file, cb) {
    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowed.includes(file.mimetype)) cb(null, true);
    else cb(new Error('Only JPG, PNG, WEBP allowed'));
  }
});

// POST /api/upload/product/:id
router.post('/product/:id', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });

    // Purani image Cloudinary se delete karo
    const [rows] = await db.execute('SELECT image_url FROM products WHERE id=?', [req.params.id]);
    if (rows.length && rows[0].image_url) {
      const oldUrl = rows[0].image_url;
      // Cloudinary public_id extract karo URL se
      if (oldUrl.includes('cloudinary.com')) {
        const parts = oldUrl.split('/');
        const fileWithExt = parts[parts.length - 1];
        const publicId = 'earthsweet-products/' + fileWithExt.split('.')[0];
        await cloudinary.uploader.destroy(publicId).catch(() => {});
      }
    }

    // Cloudinary pe upload karo (buffer se)
    const result = await new Promise((resolve, reject) => {
      const stream = cloudinary.uploader.upload_stream(
        {
          folder: 'earthsweet-products',
          transformation: [{ width: 800, height: 800, crop: 'limit', quality: 'auto' }]
        },
        (error, result) => {
          if (error) reject(error);
          else resolve(result);
        }
      );
      stream.end(req.file.buffer);
    });

    // DB update karo Cloudinary URL se
    await db.execute('UPDATE products SET image_url=? WHERE id=?', [result.secure_url, req.params.id]);

    res.json({ success: true, message: 'Image uploaded!', image_url: result.secure_url });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// DELETE /api/upload/product/:id
router.delete('/product/:id', async (req, res) => {
  try {
    const [rows] = await db.execute('SELECT image_url FROM products WHERE id=?', [req.params.id]);
    if (rows.length && rows[0].image_url) {
      const oldUrl = rows[0].image_url;
      if (oldUrl.includes('cloudinary.com')) {
        const parts = oldUrl.split('/');
        const fileWithExt = parts[parts.length - 1];
        const publicId = 'earthsweet-products/' + fileWithExt.split('.')[0];
        await cloudinary.uploader.destroy(publicId).catch(() => {});
      }
      await db.execute('UPDATE products SET image_url=NULL WHERE id=?', [req.params.id]);
    }
    res.json({ success: true, message: 'Image removed' });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;