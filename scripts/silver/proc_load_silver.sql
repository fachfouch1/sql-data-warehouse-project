CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME ;
	BEGIN Try
	
	SET @batch_start_time = GETDATE();
		PRINT '===================================';
		PRINT '**LOADING THE SILVER LAYER**';
		PRINT '===================================';
		PRINT '-----------------------------------';
		PRINT '*Loading CRM tables*';
		PRINT '-----------------------------------';
		SET @start_time = GETDATE();
		PRINT '>>Truncating crm_cust_info into Silver Layer'
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>>Inserting Data into crm_cust_info in The Silver Layer'
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER (TRIM(cst_marital_status)) = 'S' THEN 'Single'
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a'
		END cst_marital_status,
		CASE WHEN UPPER (TRIM(cst_gndr)) = 'F' THEN 'Female'
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
			ELSE 'n/a'
		END cst_gndr,
		cst_create_date
		FROM (
		SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)t WHERE flag_last = 1
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';


		-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		SET @start_time = GETDATE();
		PRINT '>>Truncating crm_prd_info into Silver Layer'
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>>Inserting Data into crm_prd_info in The Silver Layer'

		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
	
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST (prd_start_dt AS DATE) AS prd_start_dt,
			CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE )  AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';

		-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		SET @start_time = GETDATE();
		PRINT '>>Truncating crm_sales_details into Silver Layer'
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>>Inserting Data into crm_sales_details in The Silver Layer'

		INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		SELECT 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		CASE WHEN sls_order_dt <= 0 or len(sls_order_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt <= 0 or len(sls_ship_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE WHEN sls_due_dt <= 0 or len(sls_due_dt) != 8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE when sls_sales is null or sls_sales <= 0 or sls_sales != ABS(sls_price) * sls_quantity
				THEN ABS(sls_price) * sls_quantity
			else sls_sales
		END AS sls_sales,
		sls_quantity,
		case when  sls_price is null or sls_price <= 0 
				then sls_sales/NULLIF(sls_quantity, 0)
			else sls_price
		end as sls_price
		FROM bronze.crm_sales_details;
	
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';



		-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		SET @start_time = GETDATE();

		PRINT '>>Truncating erp_cust_az12 into Silver Layer'
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>>Inserting Data into erp_cust_az12 in The Silver Layer'

		INSERT INTO silver.erp_cust_az12(
		CID,
		BDATE,
		GEN
		)
		SELECT 
		CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, len(CID))
			ELSE CID
		END AS CID,
		CASE WHEN BDATE > GETDATE() THEN NULL
			ELSE BDATE
		END AS BDATE,
		CASE WHEN GEN IS NULL OR GEN = '' THEN 'n/a'
			WHEN GEN = 'F' THEN 'Female'
			WHEN GEN = 'M' THEN 'MALE'
		ELSE GEN
		END AS GEN
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';

		PRINT '-----------------------------------';
		PRINT '*Loading ERP tables*';
		PRINT '-----------------------------------';
		-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		SET @start_time = GETDATE();

		PRINT '>>Truncating erp_loc_a101 into Silver Layer'
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>>Inserting Data into erp_loc_a101 in The Silver Layer'

		INSERT INTO silver.erp_loc_a101(

		CID,
		CNTRY
		)
		SELECT 
		REPLACE(CID,'-','') CID,
		CASE WHEN CNTRY = 'USA' or CNTRY = 'US' THEN 'United States'
			WHEN CNTRY IS NULL or CNTRY = '' THEN 'n/a'
			WHEN CNTRY = 'DE' THEN 'Germany'
			ELSE CNTRY
		END CNTRY
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';

		-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		SET @start_time = GETDATE();

		PRINT '>>Truncating erp_px_cat_g1v2 into Silver Layer'
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>>Inserting Data into erp_px_cat_g1v2 in The Silver Layer'

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
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
	SET @batch_end_time = GETDATE();
	PRINT '*************************************************************************************************************';
	PRINT 'Loading Silver Layer Completed'
	PRINT '> Total load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Seconds';
	PRINT '*************************************************************************************************************';
	END TRY
	BEGIN CATCH
		PRINT '=============================';
		PRINT 'ERROR OCCURED DURING LOADING Silver LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=============================';
	END CATCH
	
END
