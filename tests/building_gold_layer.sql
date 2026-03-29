/*
===============================================================================
Quality Checks - Building Gold Layer
===============================================================================
Purpose:
    These queries show the process of validating, integrating and normalizing data when building a Gold Layer views,
    table by table, column by column across the 'silver' layer.
    These queries constitute to final script for creating a Gold Layer views.
    
Usage Notes:
    - These queries are expected to be executed seperately and sequentially, representing how the final Gold Layer views are created.
===============================================================================
*/

/*
===============================================================================
Building gold.dim_customers
===============================================================================
*/

-- Building Gold Layer
--- Starting with first object - Customers

-- We will work with tables related to the same business objects, and join them

-- First let's have an overview of the target table:

SELECT
*
FROM
silver.crm_cust_info

-- select the columns what will be presented in gold layer, and give alias

SELECT
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date
FROM
silver.crm_cust_info ci

-- We will join data from silver_cust_info -> silver.erp_cust_az12
SELECT * FROM silver.erp_cust_az12
--- We will avoid INNER JOIN - if silver.erp_cust_az12 don't have all info of customers, we will lose some
--- Start with a Master table (silver_cust_info) and use LEFT JOIN
--- Check the third customer table (silver.erp_loc_a101), we will left-join the silver_cust_info -> silver.erp_loc_a101
SELECT * FROM silver.erp_loc_a101;

--- new view:

SELECT
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
ca.bdate,
ca.gen,
la.cntry
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

--- After joining all customer tables, we need to check if any duplicates were introduced by the join-logic
--- By checking if we have any duplicates in PK

SELECT cst_id, COUNT(*) FROM
(
SELECT
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
ci.cst_gndr,
ci.cst_create_date,
ca.bdate,
ca.gen,
la.cntry
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
)
GROUP BY cst_id
HAVING COUNT(*) > 1

--- However, we have an integration issue - we have two sources of 'gender' information (cst_gndr from CRM and gen from ERP)
--- We will find not matching or incomplete values. Also NULL - as a result from joined tables, NULL will appear if no match is found

SELECT DISTINCT
ci.cst_gndr,
ca.gen
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2

--- If values don't match (Male-Female) we choose the CRM as the Master Source for truth
--- So we need to build this business rule:
---> If CRM has no useful gender, try the other source. If that's also empty, default to 'n/a'.

SELECT DISTINCT
ci.cst_gndr,
ca.gen,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender info
ELSE COALESCE(ca.gen, 'n/a')
END AS new_gen
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid
ORDER BY 1,2

--- final view:

SELECT
ci.cst_id,
ci.cst_key,
ci.cst_firstname,
ci.cst_lastname,
ci.cst_marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender info
ELSE COALESCE(ca.gen, 'n/a')
END AS new_gen,
ci.cst_create_date,
ca.bdate,
la.cntry
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

-- next we need to give columns new names, following naming concentions in General Principles
--- and sort the columns into logical groups to improve readability

SELECT
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender info
ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

--- Finally we have to create a customer dimension object, and for that we need to create surrogate key so we can later connect data model

CREATE VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender info
ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

--- Quality check of the Gold Table

SELECT * FROM gold.dim_customers
SELECT distinct gender FROM gold.dim_customers

/*
===============================================================================
Building gold.dim_products
===============================================================================
*/

--- Building the 2nd object - Product

--- Inspect the source table

SELECT * FROM silver.crm_prd_info

--- Select the tables needed

SELECT 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_start_dt,
pn.prd_end_dt
FROM silver.crm_prd_info pn

--- Filter out historical date and work only with current data
--- If end date is NULL then it is current data of the product

SELECT 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_start_dt,
pn.prd_end_dt
FROM silver.crm_prd_info pn
WHERE prd_end_dt IS NULL -- Filter out all historical data

--- Join with ERP category table/ silver.crm_prd_info pn -> silver.erp_px_cat_g1v2
--- check the table first:
SELECT * FROM silver.erp_px_cat_g1v2

SELECT 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL 

--- Check that the prd_key is unique, so it can later be connected with sales

SELECT prd_key, COUNT(*) FROM
(
SELECT 
pn.prd_id,
pn.cat_id,
pn.prd_key,
pn.prd_nm,
pn.prd_cost,
pn.prd_start_dt,
pc.cat,
pc.subcat,
pc.maintenance
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL 
)
GROUP BY prd_key
HAVING COUNT(*) > 1

--- Sort the columns into logical groups to improve readability

SELECT 
pn.prd_id,
pn.prd_key,
pn.prd_nm,
pn.cat_id,
pc.cat,
pc.subcat,
pc.maintenance,
pn.prd_cost,
pn.prd_line,
pn.prd_start_dt

FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL 

--- Rename columns with meaningful names
--- This is Product Dimension Table with history, we will need to add surrogate key
--- Ordering by prd_start_dt ensures surrogate keys are assigned chronologically --
--> older products get lower keys, newer ones get higher keys. This makes the dimension more logical and easier to trace historically.
--> prd_key is added as a tiebreaker — because multiple products could share the same `prd_start_dt` --
--> Together they ensure ROW_NUMBER() always produces the exact same surrogate key for the same product on every run — which is critical because fact tables point to these keys and can't have them shifting around.

--- Finally build the dimension view

CREATE VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL 

--- Lastly, check the view so that everything is ok

SELECT * FROM gold.dim_products

/*
===============================================================================
Building gold.fact_sales
===============================================================================
*/

--- Building the 3rd object - Fact Sales

--- Inspect the source table

SELECT * FROM silver.crm_sales_details

--- Select the tables needed, give alias.

SELECT
sd.sls_ord_num,
sd.sls_prd_key,
sd.sls_cust_id,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details sd

--- This is a Fact Table (Keys(connect to dimensions), --
--> Dates (when it happened), 
--> Measures (what was measured)) -
--> Fact is connecting multiple dimensions (Star Schema)
--> We will build further this Fact Table as Star Schema, using the dimension's surrogate keys instead of this table's IDs, to easily connect facts with dimensions

--- First we will join two dimensions to get surrogate key
--> first dimension gold.dim_products pr
SELECT * FROM gold.dim_products
--> second dimesion gold.dim_customers cu
SELECT * FROM gold.dim_customers

SELECT
sd.sls_ord_num,
pr.product_key, -- Surrogate key from dim replaced sd.sls_prd_key
cu.customer_key, -- Surrogate key from dim replaced sd.sls_cust_id
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

--- Renamne columns to friendly, meaningful names
--- Columns are already sorted into logical groups for improved readability (Dimension keys -> Dates -> Measures)
--- Finally turn the query into fact model view

CREATE VIEW gold.fact_sales AS
SELECT
sd.sls_ord_num AS order_number,
pr.product_key, 
cu.customer_key, 
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id

--- Final quality check of the gold table

SELECT * FROM gold.fact_sales

--- Fact check - check if all dimension tables can successfully join to the fact table:

--> FK integrity (Dimensions): if no results, everything matches perfectly:

SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL


SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
