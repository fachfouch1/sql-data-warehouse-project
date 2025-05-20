INSERT INTO silver.erp_px_cat_g1v2 (
ID,
CAT,
SUBCAT,
MAINTENANCE
)

SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
MAINTENANCE
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT
CASE WHEN CNTRY = 'USA' or CNTRY = 'US' THEN 'United States'
	WHEN CNTRY IS NULL or CNTRY = '' THEN 'n/a'
	WHEN CNTRY = 'DE' THEN 'Germany'
	ELSE CNTRY
END CNTRY
FROM bronze.erp_loc_a101;


SELECT sls_due_dt
from bronze.crm_sales_details 
where sls_due_dt <= 0 
or len(sls_due_dt) != 8 
or sls_due_dt > 20500101
or sls_due_dt < 19000101

SELECT distinct
sls_price as old_price,
sls_quantity,
sls_sales as old_sales,
CASE when sls_sales is null or sls_sales <= 0 or sls_sales != ABS(sls_price) * sls_quantity
		THEN ABS(sls_price) * sls_quantity
	else sls_sales
END AS sls_sales,

case when  sls_price is null or sls_price <= 0 
		then sls_sales/NULLIF(sls_quantity, 0)
	else sls_price
end as sls_price

from bronze.crm_sales_details
where sls_sales != sls_price * sls_quantity
or sls_price is null or sls_quantity is null 
or sls_sales is null
or sls_price <=0 or sls_quantity <= 0 
or sls_sales <= 0

SELECT DISTINCT
MAINTENANCE
FROM bronze.erp_px_cat_g1v2
