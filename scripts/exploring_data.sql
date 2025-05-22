SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

SELECT DISTINCT country FROM gold.dim_customers

SELECT country, count(*) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

SELECT gender, count(customer_number) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

SELECT marital_status, count(customer_number) AS total_customers
FROM gold.dim_customers
GROUP BY marital_status
ORDER BY total_customers DESC



SELECT category, COUNT(product_number) AS total_product
FROM gold.dim_products
GROUP BY category
ORDER BY total_product DESC

SELECT category, avg(product_cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC

SELECT 
p.category,
sum(f.sales) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

SELECT 
c.country,
sum(f.sales) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_revenue DESC

SELECT
c.customer_number,
c.first_name,
c.last_name,
sum(f.sales) total_money
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name
ORDER BY total_money DESC


SELECT 
c.country,
sum(f.quantity) total_sold_items
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC


SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1,2,3
--SELECT DISTINCT subcategory FROM gold.dim_products

SELECT 
min(order_date) AS oldest_order_date, 
max(order_date) AS recent_order_date,
DATEDIFF(year, min(order_date), max(order_date)) AS Years --Data from a span of 4 years
FROM gold.fact_sales



SELECT 
min(birth_date) AS oldest_customer, 
max(birth_date) AS youngest_customer 
FROM gold.dim_customers

SELECT first_name,last_name ,DATEDIFF(year,birth_date,GETDATE()) AS age
FROM gold.dim_customers
ORDER BY age DESC -- Oldest customer age 109 and youngest is 39

SELECT sum(sales) AS total_sales
FROM gold.fact_sales -- Total of sales 29356250

SELECT sum(quantity) AS number_items_sold
FROM gold.fact_sales -- Number of items sold is 60423

SELECT avg(price) AS average_price
FROM gold.fact_sales -- Average price is 486


SELECT COUNT(DISTINCT order_number) AS total_n_order
FROM gold.fact_sales -- Number of orders is 27659

SELECT COUNT(DISTINCT product_key) AS number_product
FROM gold.fact_sales -- Number of products is 130

SELECT COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales --Number of customers placed order is 18484

SELECT COUNT( customer_key) AS total_customers
FROM gold.dim_customers -- Number of customers 18484

SELECT DATEDIFF(month,order_date,shiping_date) AS shipping_time
FROM gold.fact_sales 
ORDER BY shipping_time DESC

SELECT * FROM gold.fact_sales

SELECT 'Total Sales' AS measure_name, sum(sales) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Sold Items' AS measure_name, sum(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name , avg(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders Number' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products Number' AS measure_name, COUNT(DISTINCT product_key) AS measure_value FROM gold.fact_sales
UNION ALL
--SELECT 'Total Customers Number Ordered' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales
--UNION ALL
SELECT 'Total Customers Number' AS measure_name, COUNT( customer_key) AS measure_value FROM gold.dim_customers




SELECT TOP 5
p.product_name,
sum(f.sales) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC

SELECT TOP 5
p.product_name,
sum(f.sales) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue 

SELECT TOP 5
p.subcategory,
sum(f.sales) total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC

SELECT TOP 10
c.customer_number,
c.first_name,
c.last_name,
sum(f.sales) total_money
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name
ORDER BY total_money DESC

SELECT TOP 10
c.customer_number,
c.first_name,
c.last_name,
sum(f.sales) total_money
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name
ORDER BY total_money 

SELECT TOP 3
c.customer_number,
c.first_name,
c.last_name,
COUNT(DISTINCT(f.order_number)) number_of_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name
ORDER BY number_of_orders 
