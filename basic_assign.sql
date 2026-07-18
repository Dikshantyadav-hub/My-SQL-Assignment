-- CREATE DATABASE RetailDB_1;


-- USE RetailDB_1;


-- CREATE TABLE Customers (
--  customer_id INT AUTO_INCREMENT PRIMARY KEY,
--  name VARCHAR(100),
--  email VARCHAR(150) UNIQUE,
--  city VARCHAR(50),
--  signup_date DATE
-- );


-- CREATE TABLE Products (
--  product_id INT AUTO_INCREMENT PRIMARY KEY,
--  product_name VARCHAR(100),
--  category VARCHAR(50),
--  price DECIMAL(10,2)
-- );


-- CREATE TABLE Orders (
--  order_id INT AUTO_INCREMENT PRIMARY KEY,
--  customer_id INT,
--  product_id INT,
--  order_date DATE,
--  quantity INT,
--  total_amount DECIMAL(10,2),
--  payment_mode VARCHAR(50),
--  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
--  FOREIGN KEY (product_id) REFERENCES Products(product_id)
-- );
SELECT* FROM orders;
SELECT* FROM products;
--                                            ASSIGNMENT PROBLEMS 
-- 1. Fetch all customers from the database.
SELECT * FROM customers;

-- 2. Show only the customer names and their cities.
SELECT name AS customer_name, city FROM customers;

-- 3. Find customers who live in Mumbai.
SELECT name AS customer_name, city FROM customers
WHERE city='Mumbai';

-- 4. Get all orders placed after 1st August 2024.
SELECT *FROM orders
WHERE order_date>='2024-08-01';

-- 5. List all products priced greater than ₹5000.
SELECT product_name, price 
FROM products
WHERE price> 5000;

-- 6. Count how many customers exist in the system.
SELECT COUNT(name) AS total_customers 
FROM customers;

-- 7. Update a customer’s city (e.g., change Rohit Kumar’s city to Hyderabad).
SET SQL_SAFE_UPDATES=0;
UPDATE customers SET city= "heydrabad" WHERE name= 'Rohit kumar';

-- 8. Delete an order (e.g., remove order with ID = 5).
 DELETE FROM  orders WHERE order_id= 5;
 
-- 9. Display product names with their original price and price increased by 10%.
SELECT 
    product_name,
    price AS original_price,
    price * 1.10 AS increased_price
FROM 
    products;


-- 10.Show only the unique cities where customers live.
SELECT DISTINCT(city), name AS customer_live FROM CUSTOMERS;

-- 11. Get the first 3 customers who signed up.
SELECT * FROM customers
ORDER BY signup_date ASC
LIMIT 3;

-- 12.Skip the first 2 customers and fetch the next 3 customers.
SELECT * FROM customers 
LIMIT 3 OFFSET 2;

-- 13.Find products with prices between ₹2000 and ₹6000.
SELECT * FROM products
WHERE price BETWEEN 2000 AND 6000;

-- 14.Find customers who are from Mumbai OR Chennai.
SELECT name FROM customers
WHERE city= 'Mumbai' OR 'Chennai';

-- 15.Find customers who are NOT from Delhi.
SELECT * FROM customers
WHERE city!= 'delhi';
-- 16.Find orders that are NOT paid by UPI.
SELECT order_id, order_date, payment_mode FROM orders 
WHERE payment_mode!= 'UPI'; 

-- 17.Get the average order amount across all orders.
SELECT AVG(total_amount) AS Average_amount FROM orders;
-- 18.Show the highest order amount.
SELECT  max(total_amount)FROM orders;

-- 19.Show the lowest product price.
SELECT  min(price)   AS lowest_price FROM products;

-- 20.Find the total money spent across all orders.
SELECT SUM(total_amount) AS total_money_spent FROM orders;