EXECUTE bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME ;
	BEGIN Try
		SET @batch_start_time = GETDATE();
		PRINT '===================================';
		PRINT '**LOADING THE BRONZE LAYER**';
		PRINT '===================================';
		PRINT '-----------------------------------';
		PRINT '*Loading crm tables*';
		PRINT '-----------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: crm_cust_info <<';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>> Inserting data to table: crm_cust_info <<';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Ahmed\Desktop\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-------------------------------------------------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: crm_prd_info <<';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>> Inserting data to table: crm_prd_info <<';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Ahmed\Desktop\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-------------------------------------------------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: crm_sales_details <<';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Inserting data to table: crm_sales_details <<';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Ahmed\Desktop\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-------------------------------------------------------------------------------------------';

		PRINT '-----------------------------------';
		PRINT '*Loading erp tables*';
		PRINT '-----------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: erp_cust_az12 <<';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>> Inserting data to table: erp_cust_az12 <<';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Ahmed\Desktop\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-------------------------------------------------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: erp_loc_a101 <<';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>> Inserting data to table: erp_loc_a101 <<';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Ahmed\Desktop\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-------------------------------------------------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: erp_px_cat_g1v2 <<';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>> Inserting data to table: erp_px_cat_g1v2 <<';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Ahmed\Desktop\SQL Data Warehouse Project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
		PRINT '-------------------------------------------------------------------------------------------';
	SET @batch_end_time = GETDATE();
	PRINT '*************************************************************************************************************';
	PRINT 'Loading Bronze Layer Completed'
	PRINT '> Total load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Seconds';
	PRINT '*************************************************************************************************************';
	END TRY
	BEGIN CATCH
		PRINT '=============================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=============================';
	END CATCH
END
