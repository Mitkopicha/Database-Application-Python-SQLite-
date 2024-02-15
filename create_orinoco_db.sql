-- Reset (safe for dev)
DROP TABLE IF EXISTS ordered_products;
DROP TABLE IF EXISTS shopper_orders;
DROP TABLE IF EXISTS basket_contents;
DROP TABLE IF EXISTS shopper_baskets;
DROP TABLE IF EXISTS product_sellers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sellers;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS shoppers;

-- Shoppers
CREATE TABLE shoppers (
  shopper_id INTEGER PRIMARY KEY AUTOINCREMENT,
  shopper_first_name TEXT NOT NULL,
  shopper_surname     TEXT NOT NULL,
  email               TEXT
);

-- Categories
CREATE TABLE categories (
  category_id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_description TEXT NOT NULL
);

-- Products
CREATE TABLE products (
  product_id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_description TEXT NOT NULL,
  category_id INTEGER NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Sellers
CREATE TABLE sellers (
  seller_id INTEGER PRIMARY KEY AUTOINCREMENT,
  seller_name TEXT NOT NULL
);

-- Product prices per seller
CREATE TABLE product_sellers (
  product_id INTEGER NOT NULL,
  seller_id  INTEGER NOT NULL,
  price      REAL NOT NULL,
  PRIMARY KEY (product_id, seller_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (seller_id)  REFERENCES sellers(seller_id)
);

-- Baskets
CREATE TABLE shopper_baskets (
  basket_id INTEGER PRIMARY KEY AUTOINCREMENT,
  shopper_id INTEGER NOT NULL,
  basket_created_date_time TEXT NOT NULL,
  FOREIGN KEY (shopper_id) REFERENCES shoppers(shopper_id)
);

-- Basket contents
CREATE TABLE basket_contents (
  basket_id  INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  seller_id  INTEGER NOT NULL,
  quantity   INTEGER NOT NULL,
  price      REAL NOT NULL,
  FOREIGN KEY (basket_id)  REFERENCES shopper_baskets(basket_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (seller_id)  REFERENCES sellers(seller_id)
);

-- Orders
CREATE TABLE shopper_orders (
  order_id INTEGER PRIMARY KEY AUTOINCREMENT,
  shopper_id   INTEGER NOT NULL,
  order_status TEXT NOT NULL,
  order_date   TEXT NOT NULL,
  FOREIGN KEY (shopper_id) REFERENCES shoppers(shopper_id)
);

-- Order line items
CREATE TABLE ordered_products (
  order_id  INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  seller_id  INTEGER NOT NULL,
  quantity   INTEGER NOT NULL,
  price      REAL NOT NULL,
  ordered_product_status TEXT NOT NULL,
  FOREIGN KEY (order_id)  REFERENCES shopper_orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (seller_id)  REFERENCES sellers(seller_id)
);

-- ---------- Seed data so the app runs ----------

INSERT INTO shoppers (shopper_first_name, shopper_surname, email)
VALUES ('Dimitar','Dutchev','dimitar@example.com'),
       ('Alex','Smith','alex@example.com');

INSERT INTO categories (category_description)
VALUES ('Laptops'), ('Peripherals'), ('Accessories');

INSERT INTO products (product_description, category_id)
VALUES ('Gaming Laptop', 1),
       ('Wireless Mouse', 2),
       ('Mechanical Keyboard', 2),
       ('USB-C Cable', 3);

INSERT INTO sellers (seller_name)
VALUES ('TechWorld'), ('GadgetHub');

INSERT INTO product_sellers (product_id, seller_id, price)
VALUES (1,1,999.99),
       (1,2,979.00),
       (2,1,19.99),
       (2,2,24.50),
       (3,1,79.00),
       (3,2,89.99),
       (4,1,9.99),
       (4,2,8.49);

-- Optional: a recent basket for shopper 1 (so "View Basket" shows something today)
INSERT INTO shopper_baskets (shopper_id, basket_created_date_time)
VALUES (1, datetime('now','-1 hour'));

INSERT INTO basket_contents (basket_id, product_id, seller_id, quantity, price)
VALUES (1, 2, 1, 2, 19.99),   -- 2x Wireless Mouse from TechWorld
       (1, 4, 2, 1, 8.49);    -- 1x USB-C Cable from GadgetHub

-- Optional: past order for shopper 1 (so order history shows)
INSERT INTO shopper_orders (shopper_id, order_status, order_date)
VALUES (1, 'Delivered', '2024-04-10 12:30:00');

INSERT INTO ordered_products (order_id, product_id, seller_id, quantity, price, ordered_product_status)
VALUES (1, 1, 1, 1, 999.99, 'Delivered'),
       (1, 3, 2, 1, 89.99, 'Delivered');
