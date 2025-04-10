-- Creating Tables
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_info TEXT
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    supplier_id INT REFERENCES suppliers(supplier_id) ON DELETE SET NULL
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id) ON DELETE CASCADE,
    quantity_changed INT NOT NULL,
    type VARCHAR(10) NOT NULL CHECK (type IN ('restock', 'sale')),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
--Inserting Data into the table

INSERT INTO suppliers (supplier_name, contact_info) VALUES
('ABC Traders', 'abc@example.com'),
('XYZ Distributors', 'xyz@example.com');

INSERT INTO products (product_name, description, price, stock_quantity, supplier_id) VALUES
('Notebook', '200 pages, ruled', 45.00, 100, 1),
('Pen', 'Blue ink, pack of 10', 120.00, 200, 2);

INSERT INTO transactions (product_id, quantity_changed, type) VALUES
(1, 20, 'restock'),
(1, -10, 'sale'),
(2, -5, 'sale');

--Creating views

CREATE OR REPLACE VIEW inventory_status AS
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity,
    p.price,
    s.supplier_name
FROM 
    products p
LEFT JOIN 
    suppliers s ON p.supplier_id = s.supplier_id;

CREATE OR REPLACE VIEW transaction_history AS
SELECT 
    t.transaction_id,
    p.product_name,
    t.quantity_changed,
    t.type,
    t.transaction_date
FROM 
    transactions t
JOIN 
    products p ON t.product_id = p.product_id
ORDER BY 
    t.transaction_date DESC;

-- Stored Procedures

CREATE OR REPLACE FUNCTION restock_product(prod_id INT, qty INT) RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity + qty
    WHERE product_id = prod_id;

    INSERT INTO transactions (product_id, quantity_changed, type)
    VALUES (prod_id, qty, 'restock');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sell_product(prod_id INT, qty INT) RETURNS VOID AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - qty
    WHERE product_id = prod_id AND stock_quantity >= qty;

    INSERT INTO transactions (product_id, quantity_changed, type)
    VALUES (prod_id, -qty, 'sale');
END;
$$ LANGUAGE plpgsql;
