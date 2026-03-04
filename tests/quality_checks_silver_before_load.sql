/*
===============================================================================
Quality Checks - before load
===============================================================================
Purpose:
    These queries show some examples of validating data in various scenarios,
    table by table, column by column across the 'bronze' layer, prior loading data into Silver layer.
    By validating data quality in Bronze layer tables - test queries constitute to final load script
    
    Data checks for:

    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks beofore data loading into Silver Layer.
===============================================================================
*/

-- Quality check queries for bronze.crm_cust_info - before load

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

---> If duplicates or nulls found, identify the most 'valuble' record (e.g. timestamp by creation date).

SELECT * FROM bronze.crm_cust_info
WHERE cst_id = 29466

---> rank all the duplicate entries by creation date, and pick the highest one (rank 2 and up are oldest and duplicates in this case)

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466

---> same ranking on whole table (show rank 2 and up what are the oldest, and are duplicates in this case)
---> we will get all the data we don't need, what causes duplicates in PK.

SELECT *
FROM (

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info

) WHERE flag_last != 1

---> use the same script for INSERT, except query only for unique values, and exclude nulls 

SELECT *
FROM (

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL

) WHERE flag_last = 1


-- Check for unwanted Spaces, for every column
-- Expectation: No Results
---> if the original value is not equal to the same value after trimming, it means there are spaces

SELECT cst_key
FROM bronze.crm_cust_info
WHERE cst_key != TRIM(cst_key)

----------------------------------
-- Quality check queries for bronze.crm_prd_info - before load

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

SELECT
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted Spaces, for every column
-- Expectation: No Results
---> if the original value is not equal to the same value after trimming, it means there are spaces

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers
-- Expectation: No Results

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL 

-- Data Standardization & Consistency

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders

SELECT * 
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt

--extract the first part of prd_key
-->retrieves CRM products whose category IDs are NOT found in the ERP category table

SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN
(SELECT distinct id from bronze.erp_px_cat_g1v2)

--extract the first AND second part of prd_key
-->finds products from the product table that have never been sold (no sales records exist for them).

SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info

WHERE SUBSTRING(prd_key, 7, LENGTH(prd_key)) NOT IN (
SELECT sls_prd_key 
FROM bronze.crm_sales_details
)

--> double check, by looking for specicifc prd_key in sales table:
SELECT sls_prd_key FROM bronze.crm_sales_details WHERE sls_prd_key LIKE 'FK%'

--> show all the sold products
SELECT
	prd_id,
	prd_key,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
FROM bronze.crm_prd_info

WHERE SUBSTRING(prd_key, 7, LENGTH(prd_key)) IN (
SELECT sls_prd_key 
FROM bronze.crm_sales_details
)
--- for a product with multiple price/version history records, create test column to verify correct dates
-->The end date of version 1 should equal the start date of version 2
-->compare the recorded prd_end_dt against when the next version actually started (prd_end_dt_test) to find data quality issues in product version history.
--> add "- INTERVAL 1 day" too see previous day

SELECT
	prd_id,
	prd_key,
	prd_nm,
	prd_start_dt,
	prd_end_dt,
(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) - INTERVAL '1 day' AS prd_end_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509')
------------------------

-- Quality check queries for bronze.sales_details -before load into silver
-- go over every column one by one


-- Check for unwanted Spaces, for every column
-- Expectation: No Results
---> if the original value is not equal to the same value after trimming, it means there are spaces
SELECT * FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)

--for references only
SELECT * FROM silver.crm_prd_info
SELECT * FROM silver.crm_cust_info

SELECT * FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

--Finds orphaned sales records - sales transactions that reference customers who don't exist in customer table.
SELECT * FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- check for invalid dates
-- negative numbers or zeros can't be cast to a date

SELECT 
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 

-- returns NULL if two given values are equal: otherwise, it returns the first expression
--and the length of the date must be 8
-- check for outliers by validating the boundaries of the date range

SELECT 
NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LENGTH(sls_order_dt::TEXT) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

--same apply for shipping date

SELECT 
NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 OR LENGTH(sls_ship_dt::TEXT) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

--same apply for due date

SELECT 
NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 OR LENGTH(sls_due_dt::TEXT) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101

--check for invalid date orders

SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt

--- Check data consistency: Between sale, quantity, and Price
--> Sales = Quantity * Price
--> Values must not be NULL, zero, or negative.

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,sls_quantity,sls_price


----> if sales is negative, zero, or null, derive it using Quantity and Price.
---> If Price is zero or null, calculate it using Sales or Quantity
---> if price is negative, convert it to a positive value

SELECT DISTINCT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price as old_sls_price,

CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
	THEN sls_quantity * ABS(sls_price)
ELSE sls_sales
END AS sls_sales,

CASE WHEN sls_price IS NULL OR sls_price <= 0
THEN sls_sales / NULLIF(sls_quantity, 0)
ELSE sls_price
END AS sls_price
	

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales,sls_quantity,sls_price

-----------------------------------



