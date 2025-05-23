/*
product report

1. gather essential fields such as product name,category subcategory and cost.
2 segments products by revenue to identify high performers, mid range, or low performers
3 aggregates product level metrics:
-total orders
-total sales
-total customers
-lifesapn in months
4 calculate kpis
-recency months since last sales
-average order ravenue
-average monthly revenue
*/

IF OBJECT_ID('gold.report_products','V') IS NOT NULL
	DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS
(
SELECT
p.product_name,
p.product_cost,
p.category,
p.subcategory,
p.product_key,
f.order_date,
f.order_number,
f.quantity,
f.sales,
f.customer_key

FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE order_date is not null

),

product_agg AS
(

SELECT
product_key,
product_name,
category,
subcategory,
product_cost,
COUNT(DISTINCT order_number) AS total_orders,
DATEDIFF(month,MIN(order_date),MAX(order_date)) AS lifespan,
MAX(order_date) last_order,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
round(avg(cast(sales as float)/nullif(quantity,0)),1) as avg_selling_price

FROM base_query
GROUP BY product_key,product_name,category,subcategory,product_cost
)
SELECT
product_key,
product_name,
category,
subcategory,
product_cost,
last_order,
DATEDIFF(month,last_order,GETDATE()) AS recency_in_month,
CASE WHEN total_sales > 50000 THEN 'High Performer'
	 WHEN total_sales >= 10000 THEN 'Mid Range'
	 ELSE 'Low Performer'
END AS product_performance,
lifespan,
total_orders,
total_sales,
total_customers,
total_quantity,
avg_selling_price,
CASE WHEN total_orders = 0 then 0
	ELSE total_sales/total_orders
END AS avg_order_revenue,
CASE WHEN lifespan = 0 then total_sales
	ELSE total_sales/lifespan
END AS avg_monthly_revenue
FROM product_agg
