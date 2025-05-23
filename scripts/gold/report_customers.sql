IF OBJECT_ID('gold.report_customers','V') IS NOT NULL
	DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS 

WITH base_query AS
(
SELECT
f.order_number,
f.product_key,
f.order_date,
f.sales,
f.quantity,
c.customer_key,
c.customer_number,
DATEDIFF(year, c.birth_date, GETDATE()) AS age,
CONCAT(c.first_name,' ',c.last_name) AS customer_name
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE order_date is not null 
)
, customer_agg AS
(

SELECT
customer_key,
customer_number,
age,
customer_name,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key,customer_name,customer_number,age
)

SELECT
customer_key,
customer_name,
customer_number,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age Between 20 and 29 THEN '20-29'
	 WHEN age Between 30 and 39 THEN '30-39'
	 WHEN age Between 40 and 49 THEN '40-49'
	 ELSE '50 and above'
END age_group,

CASE WHEN lifespan >= 12 and total_sales > 5000 THEN 'VIP'
	 WHEN lifespan >= 12 and total_sales <= 5000 THEN 'Regular'
	 ELSE 'New'
END customer_segment,
total_orders,
total_sales,
DATEDIFF(month, last_order, GETDATE()) AS recency,
total_quantity,
total_products,
last_order,
lifespan,
-- average order value
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales/total_orders
END AS avg_order_value,
-- average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales/lifespan
END AS avg_monthly_spend
FROM customer_agg

GO
