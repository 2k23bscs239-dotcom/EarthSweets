// fix-admin.js - EarthSweet Admin Password Fix
// -----------------------------------------------
// Is file ko earthsweet-backend folder mein rakh kar run karo:
//   node fix-admin.js
// -----------------------------------------------

require('dotenv').config();
const bcrypt = require('bcryptjs');
const db = require('./database/db');

async function fixAdmin() {
  try {
    const username = 'earthsweet_admin';
    const password = 'Admin@123';
    const fullName = 'EarthSweet Admin';

    console.log('🔄 Admin account fix kar raha hai...');

    // Hash banao
    const hash = await bcrypt.hash(password, 10);

    // Purana record delete karo
    await db.execute('DELETE FROM admins WHERE username = ?', [username]);

    // Naya admin insert karo
    await db.execute(
      'INSERT INTO admins (username, password, full_name, role, is_active) VALUES (?,?,?,?,?)',
      [username, hash, fullName, 'super_admin', true]
    );

    console.log('✅ Admin successfully create ho gaya!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('   Username : earthsweet_admin');
    console.log('   Password : Admin@123');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Ab localhost:5000/admin.html par login karo.');

    process.exit(0);
  } catch (e) {
    console.error('❌ Error:', e.message);
    process.exit(1);
  }
}

fixAdmin();