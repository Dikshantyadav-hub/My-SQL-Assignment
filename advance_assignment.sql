-- USE retaildb_3;
-- -- 1. Customers 
-- CREATE TABLE Customers ( 
-- customer_id INT AUTO_INCREMENT PRIMARY KEY, 
-- name VARCHAR(100), 
-- email VARCHAR(100), 
-- city VARCHAR(50), 
-- signup_date DATE 
-- ); -- 2. Suppliers 
-- CREATE TABLE Suppliers ( 
-- supplier_id INT AUTO_INCREMENT PRIMARY KEY, 
-- supplier_name VARCHAR(100), 
-- contact_email VARCHAR(100), 
-- city VARCHAR(50) 
-- ); -- 3. Shippers 
-- CREATE TABLE Shippers ( 
-- shipper_id INT AUTO_INCREMENT PRIMARY KEY, 
-- shipper_name VARCHAR(100), 
-- contact VARCHAR(100) 
-- ); -- 4. Payment Methods 
-- CREATE TABLE Payment_Methods ( 
-- payment_id INT AUTO_INCREMENT PRIMARY KEY, 
-- payment_type VARCHAR(50) UNIQUE 
-- ); -- 5. Products 
-- CREATE TABLE Products ( 
-- product_id INT AUTO_INCREMENT PRIMARY KEY, 
-- product_name VARCHAR(100), 
-- category VARCHAR(50), 
-- price DECIMAL(10,2), 
-- stock_qty INT, 
-- supplier_id INT, 
-- FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) 
-- ); -- 6. Orders (normalized, no total_amount column) 
-- CREATE TABLE Orders ( 
-- order_id INT AUTO_INCREMENT PRIMARY KEY, 
-- customer_id INT, 
-- order_date DATE, 
-- payment_id INT, 
-- shipper_id INT, 
-- FOREIGN KEY (customer_id) REFERENCES Customers(customer_id), 
-- FOREIGN KEY (payment_id) REFERENCES Payment_Methods(payment_id), 
-- FOREIGN KEY (shipper_id) REFERENCES Shippers(shipper_id) 
-- ); -- 7. Order_Items 
-- CREATE TABLE Order_Items ( 
-- order_item_id INT AUTO_INCREMENT PRIMARY KEY, 
-- order_id INT, 
-- product_id INT, 
-- quantity INT, 
-- price_each DECIMAL(10,2), 
-- FOREIGN KEY (order_id) REFERENCES Orders(order_id), 
-- FOREIGN KEY (product_id) REFERENCES Products(product_id) 
-- ); 
SELECT *FROM customers;
SELECT *FROM order_items;
SELECT *FROM orders;
SELECT *FROM payment_methords;
SELECT *FROM products;
SELECT *FROM shippers;
SELECT *FROM suppliers;
--                              QUESTIONS
 -- a) Joins, Group By, Order By, Aggregations: 
-- 1. Find the total revenue collected by each shipper. 
SELECT o.shipper_id, s.shipper_name,  COUNT(o.order_id) AS total_order_placed, SUM(oi.quantity*oi.price_each) AS total_revenue
FROM orders o
LEFT JOIN order_items oi
ON o.order_id= oi.order_id
INNER JOIN shippers s 
ON o.shipper_id= s.shipper_id
GROUP BY o.shipper_id;

-- 2. Show the top 5 highest-spending customers along with their total payments. 
SELECT o.customer_id, COUNT(oi.order_id) AS total_orders, SUM(oi.quantity*oi.price_each) AS total_purchase
FROM order_items oi
LEFT JOIN orders o 
ON oi.order_id=o.order_id
GROUP BY  o.customer_id
ORDER BY  total_purchase DESC
LIMIT 5;

-- 3. Find product categories where the average selling price is greater than 8000. 
SELECT category, AVG(price) AS avg_selling_price
FROM products
GROUP BY category
HAVING  AVG(price)>8000;

-- 4. Show the total number of orders placed per city, sorted by highest to lowest.
SELECT DISTINCT c.city, COUNT(o.order_id) AS total_orders
FROM customers c 
LEFT JOIN orders o 
ON c.customer_id=o.customer_id
GROUP BY  c.city
ORDER BY total_orders DESC;
 
-- 5. Find suppliers who supply more than 1 product category. 
SELECT s.*, COUNT(DISTINCT p.category) AS number_of_product_category
FROM suppliers s 
LEFT JOIN products p 
ON s.supplier_id=p.supplier_id
GROUP BY supplier_id
HAVING number_of_product_category>=1;

-- 6. Show each order along with the number of items it contains. 
SELECT o.order_id, oi.quantity AS total_item_contains
FROM  orders o
JOIN order_items oi
ON o.order_id=oi.order_id
ORDER BY o.order_id ASC;

-- b)    Subqueries – Nested & Correlated: 
-- 7. Find customers who have spent more than the average spending of all customers. 
SELECT c.customer_id, c.name,
       SUM(oi.quantity * oi.price_each) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
HAVING total_spent >
( SELECT AVG(total)
  FROM ( SELECT SUM(oi.quantity * oi.price_each) AS total
      FROM Orders o
      JOIN Order_Items oi ON o.order_id = oi.order_id
      GROUP BY o.customer_id) x );
      
-- 8. List all products whose price is higher than the average product price in their category.
SELECT *
FROM Products p
WHERE price >
( SELECT AVG(price)
  FROM Products
  WHERE category = p.category );
  
-- 9. Show customers who placed at least one order with total_amount greater than 50,000. 
SELECT DISTINCT c.customer_id, c.name
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name, o.order_id
HAVING SUM(oi.quantity * oi.price_each) > 50000;

-- 10. Find customers who placed more orders than the average number of orders per customer. 
SELECT customer_id, COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
HAVING total_orders> ANY(SELECT AVG(order_id)
FROM orders
GROUP BY customer_id );

-- 11. Find the most expensive product(s) in the catalog. 
SELECT product_id, product_name, category, price
FROM products
WHERE price=(SELECT MAX(price) FROM products);

-- c)    Window Functions: 
-- 12. Rank customers based on their total spending. 
SELECT o.customer_id, c.name,  SUM(oi.quantity*oi.price_each) AS total_spending, RANK() OVER( ORDER BY SUM(oi.quantity*oi.price_each) DESC) AS rank_on_total_spending
FROM orders o 
LEFT JOIN customers c 
ON o.customer_id= c.customer_id
JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY o.customer_id, c.name;

-- 13. Find cumulative sales amount by order date. 
SELECT o.order_date, SUM(oi.quantity*oi.price_each) AS sales, SUM(SUM(oi.quantity*oi.price_each)) OVER(ORDER BY o.order_date) AS cumulative_sales
FROM orders o 
LEFT JOIN order_items oi
ON o.order_id=oi.order_id
GROUP BY o.order_date;

-- 14. Get each customer’s order count and show their percentage contribution. 
SELECT c.customer_id, c.name,
       COUNT(o.order_id) AS order_count,
       ROUND(COUNT(o.order_id) * 100.0 /
       (SELECT COUNT(*) FROM Orders), 2) AS percentage
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- 15. Show the most recent order per customer. 
SELECT*
FROM(SELECT DISTINCT customer_id, order_date, RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS order_rank FROM orders) AS abc
WHERE abc.order_rank =1;

-- 16. List each product with its sales quantity and rank products within each category  by total sales.
SELECT p.product_id, p.product_name, p.category,
       SUM(oi.quantity) AS total_qty,
       RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC) AS rank_no
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category;

-- d)    CTE & Case: 
-- 17. Categorize products as ‘High’, ‘Medium’, or ‘Low’ price using CASE. 
SELECT product_name, price,
CASE 
WHEN price<= 5000 THEN "Low"
WHEN price BETWEEN 5000 AND 10000 THEN "Medium"
ELSE "High"
END AS product_category
FROM products
ORDER BY price DESC;

-- 18. Use a CTE to find top 3 customers by spending. 
WITH Spending AS (
  SELECT c.customer_id, c.name,
         SUM(oi.quantity * oi.price_each) AS total_spent
  FROM Customers c
  JOIN Orders o ON c.customer_id = o.customer_id
  JOIN Order_Items oi ON o.order_id = oi.order_id
  GROUP BY c.customer_id, c.name
)
SELECT * FROM Spending
ORDER BY total_spent DESC
LIMIT 3;
-- 19. Use a CTE with CASE to classify customers by loyalty (based on number of 
-- orders). 
WITH CustomerOrderCounts AS (
    SELECT c.customer_id, c.name,
           COUNT(o.order_id) AS order_count
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.name)
SELECT customer_id, name, order_count,
       CASE
           WHEN order_count >= 10 THEN 'High Loyalty'
           WHEN order_count >= 5 THEN 'Medium Loyalty'
           ELSE 'Low Loyalty'
       END AS loyalty_level
FROM CustomerOrderCounts
ORDER BY order_count DESC;

-- 20. Find monthly revenue growth percentage compared to the previous month. 
WITH MonthlyRevenue AS ( SELECT DATE_FORMAT(o.order_date, '%Y-%m-01') AS month,
           SUM(oi.quantity * oi.price_each) AS revenue
    FROM Orders o
    JOIN Order_Items oi ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m-01')),
RevenueGrowth AS (SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_revenue,
           ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 /
               NULLIF(LAG(revenue) OVER (ORDER BY month), 0),2 ) AS growth_percentage
    FROM MonthlyRevenue)
SELECT * FROM RevenueGrowth;

-- 21. Find top 2 customers per city based on total spending. 
WITH CustomerSpending AS ( SELECT c.customer_id, c.name, c.city,
           SUM(oi.quantity * oi.price_each) AS total_spent
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN Order_Items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.name, c.city),
RankedCustomers AS (SELECT *,RANK() OVER (PARTITION BY city ORDER BY total_spent DESC) AS city_rank
    FROM CustomerSpending)
SELECT customer_id, name, city, total_spent
FROM RankedCustomers
WHERE city_rank <= 2
ORDER BY city, total_spent DESC;

-- e)   Miscellaneous Advanced Joins & Aggregations 
-- 22. Find top 3 cities with highest sales revenue including shipper name. 
WITH a AS(
SELECT  c.city, SUM(oi.quantity*oi.price_each) AS sales, s.shipper_name
FROM orders o 
LEFT JOIN order_items oi
ON o.order_id=oi.order_id
LEFT JOIN customers c 
ON o.customer_id= c.customer_id
LEFT JOIN shippers s 
ON o.shipper_id=s.shipper_id
GROUP BY  c.city,s.shipper_name )
SELECT *from a
ORDER BY sales DESC
LIMIT 3;

-- 23. List all orders with customer name, product name, supplier, and shipper. 
SELECT o.order_id, c.name AS customer_name, sh.shipper_name AS supplier, p.product_name, s.supplier_name
FROM orders o 
LEFT JOIN customers c 
ON o.customer_id=c.customer_id
 LEFT JOIN shippers sh
ON o.shipper_id=sh.shipper_id 
LEFT JOIN order_items oi
ON oi.order_id=o.order_id
LEFT JOIN products p 
ON oi.product_id= p.product_id
JOIN suppliers s
ON p.supplier_id= s.supplier_id
ORDER BY o.order_id ASC;

-- 24. Show total sales per supplier along with average order value. 
SELECT s.supplier_id, s.supplier_name,
       SUM(oi.quantity * oi.price_each) AS total_sales,
       ROUND(
           SUM(oi.quantity * oi.price_each) /
           COUNT(DISTINCT o.order_id), 2
       ) AS avg_order_value
FROM Suppliers s
JOIN Products p ON s.supplier_id = p.supplier_id
JOIN Order_Items oi ON p.product_id = oi.product_id
JOIN Orders o ON oi.order_id = o.order_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY total_sales DESC;
-- 25. Show product categories that contributed more than 30% of total sales revenue. 
SELECT 
    category,
    category_revenue,
    ROUND(category_revenue / total_revenue * 100, 2) AS percent_contribution
FROM (
    SELECT 
        p.category,
        SUM(oi.quantity * oi.price_each) AS category_revenue,
        SUM(SUM(oi.quantity * oi.price_each)) OVER () AS total_revenue
    FROM Products p
    JOIN Order_Items oi 
        ON p.product_id = oi.product_id
    GROUP BY p.category
) t
WHERE category_revenue / total_revenue > 0.30
ORDER BY percent_contribution DESC;