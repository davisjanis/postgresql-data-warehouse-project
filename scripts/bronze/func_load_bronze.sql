/*
===============================================================================
Stored Function: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored function loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `COPY` command to load data from CSV files to bronze tables.
    - Tracks and logs the duration of each table load operation.
    
Parameters:
    None. 
    This stored function does not accept any parameters.
    
Returns:
    void - The function completes successfully without returning a value.
    
Usage Example:
    SELECT bronze.load_bronze();

===============================================================================
IMPORTANT: CSV File Loading and PostgreSQL Permissions
===============================================================================
When using the COPY command to load CSV files, PostgreSQL requires read access 
to the file system location where the CSV files are stored. You may encounter 
permission errors such as:

    ERROR: could not open file "/path/to/file.csv" for reading: 
    Permission denied

PostgreSQL runs under a specific user account (typically 'postgres') that may 
not have permission to access files in arbitrary directories on your system.

RECOMMENDED SOLUTION:
Place your CSV files inside the PostgreSQL installation directory where the 
PostgreSQL user already has read permissions.

Example location (adjust based on your installation):
    /Library/PostgreSQL/18/datasets/

Directory structure:
    /Library/PostgreSQL/18/datasets/
    ├── source_crm/
    │   ├── cust_info.csv
    │   ├── prd_info.csv
    │   └── sales_details.csv
    └── source_erp/
        ├── loc_a101.csv
        ├── cust_az12.csv
        └── px_cat_g1v2.csv

ALTERNATIVE SOLUTIONS:
1. Grant PostgreSQL user read permissions to your file location:
   - Linux/Mac: chmod and chown commands
   - Windows: Folder properties > Security settings

2. Use COPY FROM STDIN instead of COPY FROM file (requires application code)

3. Use psql's \copy command (runs with client permissions, not server)

For this project, we use the recommended approach of storing datasets in the 
PostgreSQL directory for simplicity.
==================================================================================
*/

CREATE OR REPLACE FUNCTION bronze.load_bronze()
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  v_start_time TIMESTAMP;
  v_end_time   TIMESTAMP;
  v_duration   NUMERIC;
	v_batch_start_time TIMESTAMP;
  v_batch_end_time   TIMESTAMP;
  v_batch_duration   NUMERIC; 

BEGIN
	v_batch_start_time := clock_timestamp(); 
	
	RAISE NOTICE '===================================================';
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '===================================================';

	RAISE NOTICE '-------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '-------------------------------------';

	v_start_time := clock_timestamp();
  RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
  TRUNCATE TABLE bronze.crm_cust_info;
	RAISE NOTICE '>> Inserting data into: bronze.crm_cust_info';
  COPY bronze.crm_cust_info
  FROM '/Library/PostgreSQL/18/datasets/source_crm/cust_info.csv'
  WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
	v_end_time := clock_timestamp();
  v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC;
  RAISE NOTICE '>> Load Duration: % seconds', ROUND(v_duration, 2);
  RAISE NOTICE '>> -------';

  v_start_time := clock_timestamp();
  RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
  TRUNCATE TABLE bronze.crm_prd_info;
	RAISE NOTICE '>> Inserting data into: bronze.crm_prd_info';
  COPY bronze.crm_prd_info
  FROM '/Library/PostgreSQL/18/datasets/source_crm/prd_info.csv'
  WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
	v_end_time := clock_timestamp();
  v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC;
  RAISE NOTICE '>> Load Duration: % seconds', ROUND(v_duration, 2);
  RAISE NOTICE '>> -------';

	v_start_time := clock_timestamp();
  RAISE NOTICE '>> Truncating Table: crm_sales_details';
  TRUNCATE TABLE bronze.crm_sales_details;
	RAISE NOTICE '>> Inserting data into: crm_sales_details';
  COPY bronze.crm_sales_details
  FROM '/Library/PostgreSQL/18/datasets/source_crm/sales_details.csv'
  WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
	v_end_time := clock_timestamp();
  v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC;
  RAISE NOTICE '>> Load Duration: % seconds', ROUND(v_duration, 2);
  RAISE NOTICE '>> -------';

	RAISE NOTICE '-------------------------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '-------------------------------------';

	v_start_time := clock_timestamp();
	RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
  TRUNCATE TABLE bronze.erp_loc_a101;
	RAISE NOTICE '>> Inserting data into: bronze.erp_loc_a101';
  COPY bronze.erp_loc_a101
  FROM '/Library/PostgreSQL/18/datasets/source_erp/loc_a101.csv'
  WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
	v_end_time := clock_timestamp();
  v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC;
  RAISE NOTICE '>> Load Duration: % seconds', ROUND(v_duration, 2);
   RAISE NOTICE '>> -------';

	v_start_time := clock_timestamp();
  RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
  TRUNCATE TABLE bronze.erp_cust_az12;
	RAISE NOTICE '>> Inserting data into: bronze.erp_cust_az12';
  COPY bronze.erp_cust_az12
  FROM '/Library/PostgreSQL/18/datasets/source_erp/cust_az12.csv'
  WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
	v_end_time := clock_timestamp();
  v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC;
  RAISE NOTICE '>> Load Duration: % seconds', ROUND(v_duration, 2);
  RAISE NOTICE '>> -------';
	
	v_start_time := clock_timestamp();
  RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
  TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	RAISE NOTICE '>> Inserting data into: bronze.erp_px_cat_g1v2';
  COPY bronze.erp_px_cat_g1v2
  FROM '/Library/PostgreSQL/18/datasets/source_erp/px_cat_g1v2.csv'
  WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
	v_end_time := clock_timestamp();
  v_duration := EXTRACT(EPOCH FROM (v_end_time - v_start_time))::NUMERIC;
  RAISE NOTICE '>> Load Duration: % seconds', ROUND(v_duration, 2);
  RAISE NOTICE '>> -------';

  RAISE NOTICE 'Bronze tables loaded successfully';
	
	v_batch_end_time := clock_timestamp();
  v_batch_duration := EXTRACT(EPOCH FROM (v_batch_end_time - v_batch_start_time))::NUMERIC;
  RAISE NOTICE '===================================================';
  RAISE NOTICE '>> TOTAL BATCH LOAD DURATION: % seconds', ROUND(v_batch_duration, 2);
  RAISE NOTICE '===================================================';
	
	EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
END;
$$;
