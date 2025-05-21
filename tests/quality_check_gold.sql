SELECT DISTINCT
ci.cst_gndr,
ca.GEN,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
ELSE COALESCE(ca.GEN, 'n/a')
END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 cl
ON ci.cst_key = cl.CID
ORDER BY 1,2

SELECT *
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON p.product_key = s.product_key
WHERE p.product_key is null
