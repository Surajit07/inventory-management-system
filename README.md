# inventory-management-system
A PostgreSQL-based Inventory Management System with users, suppliers, products, and transactions.  

## Technologies Used
- PostgreSQL
- SQL

## How to Use

1. Open pgAdmin or any PostgreSQL interface.
2. Run the `inventory_system.sql` file to create tables, insert sample data, and setup views & functions.

## Sample Queries

sql
-- Show all inventory
SELECT * FROM inventory_status;

-- View transactions
SELECT * FROM transaction_history;

-- Restock a product
SELECT restock_product(1, 20);

-- Sell a product
SELECT sell_product(2, 5);
