-- ============================================
-- EarthSweet Database Schema
-- MySQL / MariaDB
-- Run: mysql -u root -p < database/schema.sql
-- ============================================

CREATE DATABASE IF NOT EXISTS earthsweet_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE earthsweet_db;

-- ============================================
-- TABLE: admins
-- ============================================
CREATE TABLE IF NOT EXISTS admins (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(50) UNIQUE NOT NULL,
  password    VARCHAR(255) NOT NULL,
  email       VARCHAR(100),
  full_name   VARCHAR(100) DEFAULT 'Admin',
  role        ENUM('super_admin', 'admin', 'staff') DEFAULT 'admin',
  is_active   BOOLEAN DEFAULT TRUE,
  last_login  DATETIME,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: customers
-- ============================================
CREATE TABLE IF NOT EXISTS customers (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  full_name    VARCHAR(100) NOT NULL,
  phone        VARCHAR(20) UNIQUE NOT NULL,
  email        VARCHAR(100),
  city         VARCHAR(50),
  address      TEXT,
  password     VARCHAR(255) NOT NULL,
  is_verified  BOOLEAN DEFAULT FALSE,
  is_active    BOOLEAN DEFAULT TRUE,
  total_orders INT DEFAULT 0,
  created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_phone (phone),
  INDEX idx_city (city)
);

-- ============================================
-- TABLE: categories
-- ============================================
CREATE TABLE IF NOT EXISTS categories (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name_en     VARCHAR(50) NOT NULL,
  name_ur     VARCHAR(100),
  slug        VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  is_active   BOOLEAN DEFAULT TRUE,
  sort_order  INT DEFAULT 0,
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: products
-- ============================================
CREATE TABLE IF NOT EXISTS products (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  category_id     INT,
  name_en         VARCHAR(150) NOT NULL,
  name_ur         VARCHAR(200),
  slug            VARCHAR(150) UNIQUE NOT NULL,
  description_en  TEXT,
  description_ur  TEXT,
  price           DECIMAL(10,2) NOT NULL,
  price_wholesale DECIMAL(10,2),
  unit            VARCHAR(20) DEFAULT 'kg',
  stock_qty       INT DEFAULT 0,
  min_order_qty   INT DEFAULT 1,
  badge           VARCHAR(30),
  emoji           VARCHAR(10) DEFAULT '🌾',
  image_url       VARCHAR(255),
  is_active       BOOLEAN DEFAULT TRUE,
  is_featured     BOOLEAN DEFAULT FALSE,
  total_sold      INT DEFAULT 0,
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
  INDEX idx_category (category_id),
  INDEX idx_active (is_active),
  INDEX idx_featured (is_featured)
);

-- ============================================
-- TABLE: orders
-- ============================================
CREATE TABLE IF NOT EXISTS orders (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  order_number    VARCHAR(20) UNIQUE NOT NULL,
  customer_id     INT,
  customer_name   VARCHAR(100) NOT NULL,
  customer_phone  VARCHAR(20) NOT NULL,
  customer_city   VARCHAR(50) NOT NULL,
  delivery_address TEXT,
  
  subtotal        DECIMAL(10,2) DEFAULT 0,
  delivery_fee    DECIMAL(10,2) DEFAULT 0,
  total_amount    DECIMAL(10,2) NOT NULL,
  
  status          ENUM('pending','confirmed','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  payment_method  ENUM('cod','easypaisa','jazzcash','bank_transfer') DEFAULT 'cod',
  payment_status  ENUM('unpaid','paid','refunded') DEFAULT 'unpaid',
  
  notes           TEXT,
  admin_notes     TEXT,
  
  confirmed_at    DATETIME,
  shipped_at      DATETIME,
  delivered_at    DATETIME,
  
  created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
  INDEX idx_order_number (order_number),
  INDEX idx_status (status),
  INDEX idx_customer (customer_id),
  INDEX idx_created (created_at)
);

-- ============================================
-- TABLE: order_items
-- ============================================
CREATE TABLE IF NOT EXISTS order_items (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  order_id     INT NOT NULL,
  product_id   INT,
  product_name VARCHAR(150) NOT NULL,
  product_unit VARCHAR(20) DEFAULT 'kg',
  quantity     INT NOT NULL DEFAULT 1,
  unit_price   DECIMAL(10,2) NOT NULL,
  total_price  DECIMAL(10,2) NOT NULL,
  created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL,
  INDEX idx_order (order_id)
);

-- ============================================
-- TABLE: contact_messages
-- ============================================
CREATE TABLE IF NOT EXISTS contact_messages (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  name         VARCHAR(100) NOT NULL,
  phone        VARCHAR(20),
  email        VARCHAR(100),
  message      TEXT NOT NULL,
  is_read      BOOLEAN DEFAULT FALSE,
  reply        TEXT,
  replied_at   DATETIME,
  created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_read (is_read)
);

-- ============================================
-- TABLE: delivery_cities
-- ============================================
CREATE TABLE IF NOT EXISTS delivery_cities (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  city_name     VARCHAR(50) NOT NULL,
  delivery_fee  DECIMAL(8,2) DEFAULT 200,
  is_active     BOOLEAN DEFAULT TRUE,
  sort_order    INT DEFAULT 0
);

-- ============================================
-- TABLE: site_settings
-- ============================================
CREATE TABLE IF NOT EXISTS site_settings (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  setting_key  VARCHAR(50) UNIQUE NOT NULL,
  setting_val  TEXT,
  updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================
-- SEED DATA
-- ============================================

-- Default admin (password: Admin@EarthSweet2024)
INSERT IGNORE INTO admins (username, password, full_name, role) VALUES
('earthsweet_admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'EarthSweet Admin', 'super_admin');

-- Categories
INSERT IGNORE INTO categories (name_en, name_ur, slug, description) VALUES
('Gur', 'گڑ', 'gur', 'Pure traditional jaggery products'),
('Shakar', 'شکر', 'shakar', 'Natural raw sugar products'),
('Sugarcane', 'گنا', 'ganna', 'Fresh sugarcane and juice products');

-- Products
INSERT IGNORE INTO products (category_id, name_en, name_ur, slug, description_en, description_ur, price, price_wholesale, unit, stock_qty, badge, emoji, is_featured) VALUES
(1, 'Pure Desi Gur', 'خالص دیسی گڑ', 'pure-desi-gur', 'Traditional stone-pressed jaggery. Rich flavor, zero additives.', 'روایتی پتھر کا گڑ، خالص اور بغیر ملاوٹ', 320.00, 280.00, 'kg', 500, 'Best Seller', '🍯', TRUE),
(1, 'Organic Gur Block', 'آرگینک گڑ بلاک', 'organic-gur-block', 'Premium 5kg block — perfect for bulk buyers and sweet shops.', 'اعلیٰ 5 کلو بلاک — بڑے خریداروں کے لیے', 1450.00, 1200.00, '5kg', 200, 'Bulk Deal', '🟫', FALSE),
(1, 'Aam Papar Gur', 'عام پاپڑ گڑ', 'aam-papar-gur', 'Soft and light gur — ideal for tea and traditional desserts.', 'نرم اور ہلکا گڑ — چائے اور مٹھائیوں کے لیے', 280.00, 240.00, 'kg', 350, 'Popular', '🌾', FALSE),
(2, 'Premium White Shakar', 'اعلیٰ سفید شکر', 'premium-shakar', 'Fine-grain raw sugar — pure and unrefined.', 'باریک قدرتی شکر، خالص اور غیر ریفائنڈ', 180.00, 155.00, 'kg', 800, 'Natural', '🍚', TRUE),
(2, 'Golden Shakar', 'سنہری شکر', 'golden-shakar', 'Coarse golden sugar crystals with natural molasses.', 'موٹے سنہری شکر کے دانے، قدرتی ملاس کے ساتھ', 200.00, 170.00, 'kg', 600, 'Premium', '🟡', FALSE),
(3, 'Fresh Sugarcane Bundle', 'تازہ گنا بنڈل', 'sugarcane-bundle', 'Fresh-cut sugarcane bundles — sweet, juicy and farm-fresh.', 'تازہ کٹا ہوا گنا، میٹھا اور رسیلا', 150.00, 120.00, 'bundle', 300, 'Fresh', '🌿', TRUE),
(3, 'Sugarcane Juice Pack', 'گنے کا رس پیک', 'sugarcane-juice', 'Cold-pressed pure sugarcane juice — no water added.', 'ٹھنڈا دبایا گیا خالص گنے کا رس، بغیر پانی', 120.00, 100.00, 'litre', 150, 'New', '🥤', FALSE),
(1, 'Mixed Gift Pack', 'مکس گفٹ پیک', 'mixed-gift-pack', 'Gur + Shakar combo gift pack — perfect for Eid and events.', 'گڑ اور شکر کا گفٹ پیک — عید اور تقریبات کے لیے', 850.00, 720.00, 'pack', 100, 'Gift', '🎁', FALSE);

-- Delivery cities
INSERT IGNORE INTO delivery_cities (city_name, delivery_fee, sort_order) VALUES
('Karachi', 300, 1), ('Lahore', 200, 2), ('Islamabad', 250, 3),
('Rawalpindi', 250, 4), ('Faisalabad', 180, 5), ('Multan', 180, 6),
('Sargodha', 100, 7), ('Gujranwala', 180, 8), ('Sialkot', 200, 9),
('Hyderabad', 300, 10), ('Peshawar', 280, 11), ('Quetta', 350, 12),
('Bahawalpur', 200, 13), ('Sukkur', 280, 14), ('Abbottabad', 280, 15),
('Mardan', 280, 16), ('Sahiwal', 180, 17), ('Okara', 180, 18),
('Dera Ghazi Khan', 220, 19), ('Jhang', 180, 20);

-- Site settings
INSERT IGNORE INTO site_settings (setting_key, setting_val) VALUES
('site_name', 'EarthSweet'),
('whatsapp', '923167348570'),
('phone', '0316-7348570'),
('address', 'Sargodha, Punjab, Pakistan'),
('business_hours', 'Mon-Sat: 8AM - 8PM'),
('free_delivery_above', '2000'),
('default_delivery_fee', '200'),
('order_prefix', 'ES');
