 -- CREATE DATABASE retaildb_2;
 
 -- USE retaildb_2;
 
 -- 1. Customers 
-- CREATE TABLE Customers ( 
-- customer_id INT AUTO_INCREMENT PRIMARY KEY, 
-- name VARCHAR(100), 
-- email VARCHAR(100), 
-- city VARCHAR(50), 
-- signup_date DATE 
-- ); 

-- 2. Suppliers 
-- CREATE TABLE Suppliers ( 
-- supplier_id INT AUTO_INCREMENT PRIMARY KEY, 
-- supplier_name VARCHAR(100), 
-- contact_email VARCHAR(100), 
-- city VARCHAR(50) 
-- );

-- 3. Products 
-- CREATE TABLE Products ( 
-- product_id INT AUTO_INCREMENT PRIMARY KEY, 
-- product_name VARCHAR(100), 
-- category VARCHAR(50), 
-- price DECIMAL(10,2), 
-- stock_qty INT, 
-- supplier_id INT, 
-- FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) 
-- ); 

-- 4. Orders 
-- CREATE TABLE Orders ( 
-- order_id INT AUTO_INCREMENT PRIMARY KEY, 
-- customer_id INT, 
-- order_date DATE, 
-- total_amount DECIMAL(10,2), 
-- payment_mode VARCHAR(50), 
-- FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) 
-- );

-- 5. Order_Items 
-- CREATE TABLE Order_Items ( 
-- order_item_id INT AUTO_INCREMENT PRIMARY KEY, 
-- order_id INT, 
-- product_id INT, 
-- quantity INT, 
-- price_each DECIMAL(10,2), 
-- FOREIGN KEY (order_id) REFERENCES Orders(order_id), 
-- FOREIGN KEY (product_id) REFERENCES Products(product_id) 
-- ); 
-- SELECT *FROM customers;
-- SELECT *FROM suppliers;
-- SELECT *FROM products;
-- SELECT *FROM orders;
-- SELECT *FROM order_Items;

 --                                       QUESTIONS
-- a) Normal Queries 
-- 1. Fetch all products along with their supplier name (INNER JOIN). 
SELECT p .product_id, p.product_name, s.supplier_name
FROM  products p 
INNER JOIN suppliers s 
ON p.supplier_id= s.supplier_id;

-- 2. Find all customers and their orders, even if they have not placed any (LEFT JOIN).
SELECT c.customer_id, c.name, o.order_id, o.order_date, o.total_amount
FROM customers c
LEFT JOIN orders o
ON c.customer_id= o.customer_id;
 
-- 3. Get all suppliers and the products they supply, even if no products exist for a supplier (RIGHT JOIN). 
SELECT s.*, p.product_name, p.price
FROM products p
RIGHT JOIN suppliers s
ON p.supplier_id= s.supplier_id;

-- 4. Show all customers and all orders (FULL OUTER JOIN simulation using UNION). 
SELECT c.*, o.*
FROM customers c
LEFT JOIN orders o 
ON c.customer_id= o.customer_id
UNION 
SELECT c.*, o.*
FROM customers c
RIGHT JOIN orders o 
ON o.customer_id= c.customer_id;

-- 5. List all products priced between ₹5000 and ₹50,000 and supplied from "Mumbai". 
 SELECT p.* 
 FROM products p 
 JOIN suppliers s 
 ON p.supplier_id= s.supplier_id
 WHERE p.price BETWEEN 5000 AND 50000
 AND s.supplier_id= (SELECT supplier_id FROM suppliers WHERE city= "mumbai");
 
-- b)  Aggregations & Group By 
-- 6. Find the total number of orders placed by each customer and show only those , who placed more than 2 (GROUP BY + HAVING). 
SELECT o.customer_id, COUNT(o.order_id) AS Total_number_orders
FROM orders o
GROUP BY customer_id
HAVING Total_number_orders >2;

-- 7. Show each supplier’s total sales value (sum of quantity × price_each). 
SELECT supplier_id, SUM(price*stock_qty) AS Total_sales
FROM products
GROUP BY supplier_id;

-- 8. Find the average, highest, and lowest price of products in each category. 
SELECT category, AVG(price) AS avg_price, MAX(price) AS highest_price, MIN(price) AS lowest_price
FROM products
GROUP BY category;

-- 9. Find the top 5 customers by total spending (ORDER BY SUM(total_amount)DESC LIMIT 5).
SELECT customer_id, SUM(total_amount) AS total_purchase
FROM orders 
GROUP BY customer_id 
ORDER BY total_purchase DESC 
LIMIT 5; 

-- 10. Show the number of unique products ordered by each customer. 
SELECT o.customer_id, COUNT(DISTINCT(oi.product_id)) AS total_products_purchase
FROM order_items oi
LEFT JOIN orders o 
ON oi.order_id= o.order_id
GROUP BY o.customer_id;

-- c)  Subqueries 
-- 11. Find customers who placed an order with an amount greater than the average order amount (subquery). 
 SELECT customer_id,order_id, order_date, total_amount AS order_amount
 FROM orders
 WHERE total_amount> (SELECT AVG(total_amount)
 FROM orders);
 
-- 12. Find products that have never been ordered (subquery with NOT IN). 
SELECT product_id, product_name
FROM products
WHERE product_id NOT IN (SELECT product_id FROM orders);

-- 13. List customers who ordered at least one product from the "Electronics" category. 
SELECT customer_id, order_id 
FROM orders
WHERE order_id IN (SELECT order_id FROM order_items 
WHERE product_id IN (SELECT product_id FROM products
WHERE category ="Electronics"));

-- 14. Get suppliers who provide products that have been ordered more than 100 times in total. 
SELECT supplier_id, product_name, SUM(stock_qty) total_stock
FROM products
GROUP BY supplier_id, product_name
HAVING total_stock> 100;
 
-- 15. Find the most expensive product(s) using a subquery with MAX(). 
SELECT * 
FROM products
WHERE price=( SELECT MAX(price) FROM products);

-- d)  Advanced Filters 
-- 16. Show orders placed by customers who live in either Mumbai, Delhi, or  Bengaluru (IN operator). 
SELECT * 
FROM orders
WHERE customer_id IN(SELECT customer_id FROM customers
WHERE city IN("Mumbai", "Delhi", "Bengaluru"));

-- 17. Show orders where payment mode is NOT UPI or Credit Card (NOT IN). 
SELECT *
FROM orders
WHERE payment_mode NOT IN (SELECT payment_mode FROM orders
WHERE payment_mode IN ("UPI","credit card"));

-- 18. Find customers who have no email address recorded (IS NULL). 
SELECT * 
FROM customers
WHERE email IS NULL;

-- 19. Show suppliers who are not from the same city as any customer (NOT IN subquery). 
SELECT * FROM suppliers
WHERE city NOT IN (SELECT DISTINCT city FROM customers);

-- 20. Get the latest 3 orders placed, skipping the first 2 (ORDER BY + LIMIT +  OFFSET).
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 3
OFFSET 2;

