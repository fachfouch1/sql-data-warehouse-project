IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
cl.CNTRY AS country,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
ELSE COALESCE(ca.GEN, 'n/a')
END AS gender,
ci.cst_marital_status AS marital_status,
ca.BDATE AS birth_date,
ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 cl
ON ci.cst_key = cl.CID
GO


  
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS 
SELECT
ROW_NUMBER() OVER (ORDER BY mp.prd_start_dt, mp.prd_key) AS product_key,
mp.prd_id AS product_id,
mp.prd_key AS product_number,
mp.prd_nm AS product_name,
mp.prd_cost AS product_cost,
mp.prd_line product_line,
mp.cat_id as category_id,
sp.CAT as category,
sp.SUBCAT as subcategory,
sp.MAINTENANCE as maintenance,
mp.prd_start_dt as starting_date

FROM silver.crm_prd_info mp
LEFT JOIN silver.erp_px_cat_g1v2 sp
ON mp.cat_id = sp.ID
WHERE mp.prd_end_dt is null
GO



IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
sd.sls_ord_num AS order_number,
pr.product_key,
cr.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shiping_date,
sd.sls_due_dt AS due_date,
sd.sls_quantity AS quantity,
sd.sls_price AS price,
sd.sls_sales AS sales
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cr
ON sd.sls_cust_id = cr.customer_id
GO
