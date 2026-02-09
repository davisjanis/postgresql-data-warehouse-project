/*
=============================================================
Create Schemas
=============================================================
Script Purpose:
    This script sets up three schemas within the datawarehouse database: 
    'bronze', 'silver', and 'gold'.

Usage:
    psql -U postgres -d datawarehouse -f 02_create_schemas.sql
*/

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Verify schemas were created
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('bronze', 'silver', 'gold')
ORDER BY schema_name;
