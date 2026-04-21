// routes/upload.js - Product Image Upload (Cloudinary)
const express = require('express');
const multer  = require('multer');
const path    = require('path');
const db      = require('../database/db');
const router  = express.Router();

const useCloudinary = !!(process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY && process.env.CLOUDINARY_API_SECRET);
let cloudinary;

if (useCloudinary) {
  cloudinary = require('cloudinary').v2;
  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key:    process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
}

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['.jpg','.jpeg','.png','.webp','.jfif'];
    allowed.includes(path.extname(file.originalname).toLowerCase()) ? cb(null,true) : cb(new Error('Only JPG/PNG/WEBP/JFIF'));
  }
});

// POST /api/upload/product/:id
router.post('/product/:id', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success:false, message:'No file uploaded' });

    let imageUrl;
    if (useCloudinary) {
      const result = await new Promise((resolve, reject) => {
        cloudinary.uploader.upload_stream(
          { folder:'earthsweet/products', resource_type:'image' },
          (err, r) => err ? reject(err) : resolve(r)
        ).end(req.file.buffer);
      });
      imageUrl = result.secure_url;
    } else {
      const fs   = require('fs');
      const dir  = path.join(__dirname,'../uploads/products');
      if (!fs.existsSync(dir)) fs.mkdirSync(dir,{recursive:true});
      const name = 'product-' + Date.now() + path.extname(req.file.originalname).toLowerCase();
      fs.writeFileSync(path.join(dir,name), req.file.buffer);
      imageUrl = '/uploads/products/' + name;
    }

    await db.execute('UPDATE products SET image_url=? WHERE id=?', [imageUrl, req.params.id]);
    res.json({ success:true, message:'Image uploaded!', image_url:imageUrl });
  } catch(e) {
    console.error('UPLOAD ERROR:', e);
    res.status(500).json({ success:false, message:e.message });
  }
});

// DELETE /api/upload/product/:id
router.delete('/product/:id', async (req, res) => {
  try {
    await db.execute('UPDATE products SET image_url=NULL WHERE id=?', [req.params.id]);
    res.json({ success:true, message:'Image removed' });
  } catch(e) {
    res.status(500).json({ success:false, message:e.message });
  }
});

module.exports = router;