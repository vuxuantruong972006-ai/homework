# Bookstore Database — ERD

## 1. Entities and attributes

**Notation:** `PK` = Primary Key, `FK` = Foreign Key, `UQ` = Unique.

### authors
- `author_id` INT — PK
- `first_name` VARCHAR(100) — required
- `last_name` VARCHAR(100) — required
- `biography` TEXT — optional
- `nationality` VARCHAR(80) — optional
- `created_at` DATETIME — default current timestamp

### publishers
- `publisher_id` INT — PK
- `name` VARCHAR(150) — UQ, required
- `address` VARCHAR(255) — optional
- `website` VARCHAR(255) — optional
- `created_at` DATETIME — default current timestamp

### categories
- `category_id` INT — PK
- `name` VARCHAR(100) — UQ, required
- `description` TEXT — optional
- `parent_category_id` INT — FK to `categories.category_id`, optional

### books
- `book_id` INT — PK
- `title` VARCHAR(255) — required
- `isbn` VARCHAR(20) — UQ, required
- `publisher_id` INT — FK to `publishers.publisher_id`
- `publication_date` DATE — optional
- `price` DECIMAL(10,2) — must be greater than 0
- `stock` INT — must be zero or greater
- `description` TEXT — optional
- `created_at` DATETIME — default current timestamp

### book_authors
- `book_id` INT — PK, FK to `books.book_id`
- `author_id` INT — PK, FK to `authors.author_id`
- `author_order` INT — default 1

### book_categories
- `book_id` INT — PK, FK to `books.book_id`
- `category_id` INT — PK, FK to `categories.category_id`

### customers
- `customer_id` INT — PK
- `full_name` VARCHAR(150) — required
- `email` VARCHAR(255) — UQ, required
- `password_hash` VARCHAR(255) — required; store a hash, never a plain-text password
- `phone` VARCHAR(30) — optional
- `address` VARCHAR(255) — optional
- `created_at` DATETIME — default current timestamp

### orders
- `order_id` INT — PK
- `customer_id` INT — FK to `customers.customer_id`
- `order_date` DATETIME — default current timestamp
- `status` ENUM — default `Pending`
- `total_amount` DECIMAL(10,2) — must be zero or greater
- `shipping_address` VARCHAR(255) — required

### order_items
- `order_item_id` INT — PK
- `order_id` INT — FK to `orders.order_id`
- `book_id` INT — FK to `books.book_id`
- `quantity` INT — greater than 0
- `unit_price` DECIMAL(10,2) — greater than 0; price captured at order time
- `subtotal` DECIMAL(10,2) — quantity multiplied by unit price
- Unique constraint on (`order_id`, `book_id`) to prevent duplicate lines for the same book in one order

### reviews
- `review_id` INT — PK
- `customer_id` INT — FK to `customers.customer_id`
- `book_id` INT — FK to `books.book_id`
- `rating` INT — from 1 to 5
- `comment` TEXT — optional
- `review_date` DATETIME — default current timestamp
- Unique constraint on (`customer_id`, `book_id`) so a customer can review a book once

## 2. Relationships and cardinality

```text
publishers (1) -------- (N) books

books (1) ------------- (N) book_authors (N) ------------- (1) authors
                         resolves books ↔ authors M:N

books (1) ------------- (N) book_categories (N) ---------- (1) categories
                         resolves books ↔ categories M:N

categories (parent) (1) -------- (N) categories (child)

customers (1) --------- (N) orders
orders (1) ------------- (N) order_items (N) ------------- (1) books
                         order_items records quantity and price per book

customers (1) --------- (N) reviews (N) ------------------ (1) books
```

## 3. Why the design is in 3NF

1. **First Normal Form (1NF):** Each column stores one value. Authors and categories are not stored as comma-separated lists inside `books`; they are represented using junction tables.
2. **Second Normal Form (2NF):** The junction tables use composite primary keys (`book_id`, `author_id`) and (`book_id`, `category_id`). Their non-key attributes depend on the complete key. The remaining tables use single-column primary keys.
3. **Third Normal Form (3NF):** Author, publisher, category, and customer details are stored in their own tables. For example, a book stores `publisher_id`, not the publisher's name, address, and website. Order items store the unit price charged at the time of purchase, preserving historical transaction information. `subtotal` is included to meet the assignment requirements and should be kept consistent with `quantity * unit_price`.

## 4. Design notes

- Foreign keys protect referential integrity.
- `CASCADE` is used for dependent junction rows and order items.
- `RESTRICT` prevents deleting referenced books, customers, authors, publishers, or categories accidentally.
- The database uses InnoDB and `utf8mb4`.
