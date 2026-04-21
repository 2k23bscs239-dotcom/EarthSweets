# 🌿 EarthSweet — Complete Backend Setup Guide

## Stack
- **Backend:** Node.js + Express.js
- **Database:** MySQL / MariaDB
- **Auth:** JWT (JSON Web Tokens)
- **Security:** Helmet, CORS, Rate Limiting, bcrypt

---

## 📁 Folder Structure

```
earthsweet-backend/
├── server.js              ← Main server (entry point)
├── package.json
├── .env.example           ← Copy to .env and fill values
├── database/
│   ├── db.js              ← MySQL connection pool
│   └── schema.sql         ← Full database schema + seed data
├── middleware/
│   └── auth.js            ← JWT authentication middleware
├── routes/
│   └── index.js           ← All API routes
└── uploads/               ← Product images (create this folder)
```

---

## 🚀 Setup Instructions

### Step 1 — Install Node.js
Download from: https://nodejs.org (version 18+)

### Step 2 — Install MySQL
Download from: https://dev.mysql.com/downloads/mysql/
Or use your hosting panel (cPanel → MySQL Databases)

### Step 3 — Clone / Upload Files
Upload all backend files to your server or hosting.

### Step 4 — Install Dependencies
```bash
cd earthsweet-backend
npm install
```

### Step 5 — Create Database
```bash
mysql -u root -p < database/schema.sql
```
Or paste schema.sql content in phpMyAdmin.

### Step 6 — Configure Environment
```bash
cp .env.example .env
nano .env   # Fill in your MySQL credentials
```

### Step 7 — Start Server
```bash
# Development
npm run dev

# Production
npm start
```

---

## 🔑 Admin Login
- **URL:** POST /api/admin/login
- **Username:** earthsweet_admin
- **Password:** Admin@EarthSweet2024

⚠️ **Change this password immediately after first login!**

---

## 📡 API Endpoints

### Public Endpoints
| Method | URL | Description |
|--------|-----|-------------|
| GET | /api/health | Server health check |
| GET | /api/products | All products |
| GET | /api/products/:slug | Single product |
| GET | /api/categories | All categories |
| GET | /api/cities | Delivery cities |
| POST | /api/auth/register | Customer register |
| POST | /api/auth/login | Customer login |
| POST | /api/orders | Place order |
| GET | /api/orders/:orderNumber | Track order |
| POST | /api/contact | Send message |

### Customer (JWT Required)
| Method | URL | Description |
|--------|-----|-------------|
| GET | /api/auth/me | My profile + orders |

### Admin (Admin JWT Required)
| Method | URL | Description |
|--------|-----|-------------|
| POST | /api/admin/login | Admin login |
| GET | /api/admin/stats | Dashboard stats |
| GET | /api/admin/orders | All orders |
| PATCH | /api/admin/orders/:id/status | Update order status |
| GET | /api/admin/products | Manage products |
| POST | /api/admin/products | Add product |
| PUT | /api/admin/products/:id | Edit product |
| DELETE | /api/admin/products/:id | Delete product |
| GET | /api/admin/customers | All customers |
| GET | /api/admin/messages | Contact messages |
| GET | /api/admin/settings | Site settings |
| PUT | /api/admin/settings | Update settings |

---

## 🌐 cPanel Hosting Deployment

1. Upload files to `public_html/api/` folder
2. Create MySQL database in cPanel → MySQL Databases
3. Import `schema.sql` via phpMyAdmin
4. Set Node.js app in cPanel → Node.js Selector
5. Set entry point: `server.js`
6. Set environment variables in cPanel
7. Click "Run NPM Install"
8. Start the app

---

## 🔗 Connect Frontend to Backend

In your `EarthSweet_Website.html`, set the API URL:
```javascript
const API_URL = 'https://yourdomain.com/api';
```

---

## 🛡️ Security Notes
- Change admin password after setup
- Use strong JWT_SECRET (min 32 characters)
- Enable HTTPS on your domain (free via Let's Encrypt)
- Set FRONTEND_URL to your actual domain in .env
