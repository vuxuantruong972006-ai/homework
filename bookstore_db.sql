-- =========================================================
-- Homework 6: Online Bookstore Database
-- MySQL / MariaDB compatible; run in phpMyAdmin or MySQL.
-- =========================================================

CREATE DATABASE IF NOT EXISTS bookstore_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookstore_db;

-- =========================================================
-- 3NF EXPLANATION
-- 1NF: Every field contains one atomic value; no lists of authors
--      or categories are stored in a book row.
-- 2NF: Junction tables use composite PKs, and their non-key
--      attributes depend on the complete composite key.
-- 3NF: Descriptive data for authors, publishers, categories and
--      customers is stored in separate tables. Books store only
--      publisher_id rather than repeating publisher details.
--      Order items preserve the unit price at purchase time.
-- =========================================================

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS authors;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    biography TEXT NULL,
    nationality VARCHAR(80) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    address VARCHAR(255) NULL,
    website VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NULL,
    parent_category_id INT NULL,
    CONSTRAINT fk_categories_parent
        FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publisher_id INT NOT NULL,
    publication_date DATE NULL,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    description TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_books_price CHECK (price > 0),
    CONSTRAINT chk_books_stock CHECK (stock >= 0),
    CONSTRAINT fk_books_publisher
        FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT chk_book_authors_order CHECK (author_order > 0),
    CONSTRAINT fk_book_authors_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_authors_author
        FOREIGN KEY (author_id) REFERENCES authors(author_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_book_categories_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_book_categories_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(30) NULL,
    address VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `orders` (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Paid','Processing','Shipped','Delivered','Cancelled')
        NOT NULL DEFAULT 'Pending',
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    shipping_address VARCHAR(255) NOT NULL,
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT uq_order_book UNIQUE (order_id, book_id),
    CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_items_unit_price CHECK (unit_price > 0),
    CONSTRAINT chk_order_items_subtotal CHECK (subtotal >= 0),
    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id) REFERENCES `orders`(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_items_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    book_id INT NOT NULL,
    rating INT NOT NULL,
    comment TEXT NULL,
    review_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_review_customer_book UNIQUE (customer_id, book_id),
    CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_reviews_customer
        FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_book
        FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------
-- Sample data: 6 authors
-- -------------------------
INSERT INTO authors (first_name, last_name, biography, nationality) VALUES
('Nguyen', 'Nhat Anh', 'Vietnamese writer known for novels for young readers.', 'Vietnamese'),
('Paulo', 'Coelho', 'Brazilian novelist.', 'Brazilian'),
('Yuval Noah', 'Harari', 'Historian and author.', 'Israeli'),
('Robert', 'C. Martin', 'Software engineer and author.', 'American'),
('James', 'Clear', 'Writer focused on habits and self-improvement.', 'American'),
('George', 'Orwell', 'English novelist and essayist.', 'British');

-- -------------------------
-- Sample data: 4 publishers
-- -------------------------
INSERT INTO publishers (name, address, website) VALUES
('Tre Publishing House', 'Ho Chi Minh City, Vietnam', 'https://www.nxbtre.com.vn'),
('Nha Nam Publishing', 'Hanoi, Vietnam', 'https://nhanam.vn'),
('HarperOne', 'New York, USA', 'https://www.harpercollins.com'),
('Penguin Random House', 'London, UK', 'https://www.penguinrandomhouse.com');

-- -------------------------
-- Sample data: 6 categories
-- -------------------------
INSERT INTO categories (name, description, parent_category_id) VALUES
('Fiction', 'Fictional stories and novels.', NULL),
('Non-fiction', 'Informational and factual books.', NULL),
('Technology', 'Computing and technology.', 2),
('Personal Development', 'Habits and personal growth.', 2),
('Classic Literature', 'Influential classic works.', 1),
('History', 'History and historical analysis.', 2);

-- -------------------------
-- Sample data: 8 books
-- -------------------------
INSERT INTO books (title, isbn, publisher_id, publication_date, price, stock, description) VALUES
('Mat Biec', '9786041189991', 1, '2019-01-01', 85000.00, 35, 'A Vietnamese coming-of-age novel.'),
('The Alchemist', '9780062315007', 3, '2014-04-15', 210000.00, 20, 'A novel about following a personal dream.'),
('Sapiens', '9780062316097', 3, '2015-02-10', 320000.00, 15, 'A broad history of humankind.'),
('Clean Code', '9780132350884', 4, '2008-08-01', 450000.00, 12, 'A guide to writing readable software.'),
('Atomic Habits', '9780735211292', 4, '2018-10-16', 280000.00, 40, 'A practical guide to building habits.'),
('1984', '9780451524935', 4, '1950-07-01', 160000.00, 25, 'A dystopian classic novel.'),
('Animal Farm', '9780451526342', 4, '1945-08-17', 135000.00, 18, 'A political allegorical novella.'),
('Toi Thay Hoa Vang Tren Co Xanh', '9786041188888', 1, '2018-05-01', 95000.00, 28, 'A Vietnamese novel about childhood and family.');

-- -------------------------
-- M:N links: books and authors
-- -------------------------
INSERT INTO book_authors (book_id, author_id, author_order) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(5, 5, 1),
(6, 6, 1),
(7, 6, 1),
(8, 1, 1);

-- -------------------------
-- M:N links: books and categories
-- -------------------------
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), (1, 5),
(2, 1),
(3, 2), (3, 6),
(4, 2), (4, 3),
(5, 2), (5, 4),
(6, 1), (6, 5),
(7, 1), (7, 5),
(8, 1);

-- -------------------------
-- Sample data: 5 customers
-- Password values are illustrative hashes/placeholders only.
-- In a real application, use a secure password-hashing function.
-- -------------------------
INSERT INTO customers (full_name, email, password_hash, phone, address) VALUES
('Tran Minh Anh', 'minhanh@example.com', '$2y$10$examplehash000000000000000000000000000000000000000000000', '0901000001', 'Hanoi, Vietnam'),
('Le Quang Huy', 'quanghuy@example.com', '$2y$10$examplehash000000000000000000000000000000000000000000000', '0901000002', 'Hai Phong, Vietnam'),
('Pham Thu Ha', 'thuha@example.com', '$2y$10$examplehash000000000000000000000000000000000000000000000', '0901000003', 'Da Nang, Vietnam'),
('Do Duc Long', 'duclong@example.com', '$2y$10$examplehash000000000000000000000000000000000000000000000', '0901000004', 'Ninh Binh, Vietnam'),
('Vu Mai Linh', 'mailinh@example.com', '$2y$10$examplehash000000000000000000000000000000000000000000000', '0901000005', 'Ho Chi Minh City, Vietnam');

-- -------------------------
-- Sample data: 6 orders
-- -------------------------
INSERT INTO `orders` (customer_id, order_date, status, total_amount, shipping_address) VALUES
(1, '2026-10-01 10:15:00', 'Delivered', 295000.00, 'Hanoi, Vietnam'),
(2, '2026-10-02 11:20:00', 'Shipped', 660000.00, 'Hai Phong, Vietnam'),
(3, '2026-10-03 14:30:00', 'Processing', 450000.00, 'Da Nang, Vietnam'),
(4, '2026-10-04 09:05:00', 'Paid', 295000.00, 'Ninh Binh, Vietnam'),
(5, '2026-10-05 16:45:00', 'Pending', 460000.00, 'Ho Chi Minh City, Vietnam'),
(1, '2026-10-06 13:00:00', 'Delivered', 500000.00, 'Hanoi, Vietnam');

-- -------------------------
-- Sample data: 14 order items
-- -------------------------
INSERT INTO order_items (order_id, book_id, quantity, unit_price, subtotal) VALUES
(1, 1, 1, 85000.00, 85000.00),
(1, 2, 1, 210000.00, 210000.00),
(2, 3, 1, 320000.00, 320000.00),
(2, 5, 1, 280000.00, 280000.00),
(2, 1, 1, 60000.00, 60000.00),
(3, 4, 1, 450000.00, 450000.00),
(4, 6, 1, 160000.00, 160000.00),
(4, 7, 1, 135000.00, 135000.00),
(5, 5, 1, 280000.00, 280000.00),
(5, 8, 1, 95000.00, 95000.00),
(5, 1, 1, 85000.00, 85000.00),
(6, 3, 1, 320000.00, 320000.00),
(6, 8, 1, 95000.00, 95000.00),
(6, 1, 1, 85000.00, 85000.00);

-- -------------------------
-- Sample data: 10 reviews
-- -------------------------
INSERT INTO reviews (customer_id, book_id, rating, comment, review_date) VALUES
(1, 1, 5, 'A touching and memorable story.', '2026-10-07 10:00:00'),
(2, 2, 4, 'Inspirational and easy to read.', '2026-10-07 11:00:00'),
(3, 3, 5, 'Interesting overview of human history.', '2026-10-08 09:00:00'),
(4, 4, 4, 'Useful principles for software development.', '2026-10-08 12:00:00'),
(5, 5, 5, 'Practical and motivating.', '2026-10-09 13:00:00'),
(1, 6, 5, 'A powerful classic.', '2026-10-09 15:00:00'),
(2, 7, 4, 'Short but thought-provoking.', '2026-10-10 08:00:00'),
(3, 8, 5, 'A warm story about family.', '2026-10-10 10:00:00'),
(4, 2, 4, 'A good book to reflect on goals.', '2026-10-11 16:00:00'),
(5, 3, 5, 'Well researched and engaging.', '2026-10-12 17:00:00');

-- -------------------------
-- Quick verification queries
-- -------------------------
SELECT 'authors' AS table_name, COUNT(*) AS row_count FROM authors
UNION ALL SELECT 'publishers', COUNT(*) FROM publishers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'book_authors', COUNT(*) FROM book_authors
UNION ALL SELECT 'book_categories', COUNT(*) FROM book_categories
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'orders', COUNT(*) FROM `orders`
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;
