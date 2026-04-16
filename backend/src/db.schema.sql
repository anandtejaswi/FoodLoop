-- ============================================================
-- FoodLoop Database Schema  –  MySQL
-- Run: mysql -u root -p < db.schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS foodloop_db;

USE foodloop_db;

-- ── Users ─────────────────────────────────────────────────────
-- USERS TABLE
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  role VARCHAR(10),   -- giver / taker
  avatar_url VARCHAR(255),
  impact_score INT DEFAULT 0,
  points INT DEFAULT 0,
  rating DOUBLE DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- FOOD ITEMS TABLE
CREATE TABLE food_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  giver_id INT NOT NULL,
  title VARCHAR(150) NOT NULL,
  category VARCHAR(50) DEFAULT 'other',
  description TEXT,
  quantity INT DEFAULT 1,
  quantity_unit VARCHAR(50) DEFAULT 'portions',
  lat DOUBLE NOT NULL,
  lng DOUBLE NOT NULL,
  address VARCHAR(255),
  photo_url VARCHAR(255),
  giver_phone VARCHAR(20),
  status VARCHAR(20) DEFAULT 'available',  -- available / claimed / completed
  expiry_time DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (giver_id) REFERENCES users(id) ON DELETE CASCADE
);

-- REQUESTS TABLE
CREATE TABLE requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  food_id INT,
  taker_id INT,
  status VARCHAR(20),  -- pending / accepted / rejected
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (food_id) REFERENCES food_items(id),
  FOREIGN KEY (taker_id) REFERENCES users(id)
);

-- REVIEWS TABLE
CREATE TABLE reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT,
  reviewer_id INT,
  rating INT,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES requests(id),
  FOREIGN KEY (reviewer_id) REFERENCES users(id)
);

-- MESSAGES TABLE
CREATE TABLE messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT,
  sender_id INT,
  content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (request_id) REFERENCES requests(id),
  FOREIGN KEY (sender_id) REFERENCES users(id)
);