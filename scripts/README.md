# Data Warehouse Setup

## Prerequisites
- PostgreSQL 12+ installed
- Access to a PostgreSQL user with database creation privileges (e.g., `postgres`)

## Setup Instructions

### Option 1: Using psql

1. **Create the database:**
```
   psql -U postgres -d postgres -f 01_create_database.sql
```

2. **Create the schemas:**
```
   psql -U postgres -d datawarehouse -f 02_create_schemas.sql
```

### Option 2: Using pgcli

1. **Create the database:**
```
   pgcli -U postgres -d postgres < 01_create_database.sql
```

2. **Create the schemas:**
```
   pgcli -U postgres -d datawarehouse < 02_create_schemas.sql
```

### Option 3: Interactive (pgAdmin or terminal)

1. Connect to your PostgreSQL server
2. Run `01_create_database.sql`
3. Switch to the `datawarehouse` database
4. Run `02_create_schemas.sql`

## Database Structure
```
datawarehouse/
├── bronze/     # Raw/landing zone schema
├── silver/     # Cleaned/standardized schema
└── gold/       # Aggregated/business-ready schema
```

## Verification

To verify the setup was successful:
```
-- Connect to datawarehouse
\c datawarehouse

-- List all schemas
\dn

-- Or query:
SELECT schema_name 
FROM information_schema.schemata 
WHERE schema_name IN ('bronze', 'silver', 'gold');
```

## Warning

Running `01_create_database.sql` will **DROP** the existing `datawarehouse` database and all its data. Ensure you have backups before proceeding.

## Troubleshooting

### "database is being accessed by other users"

If you get this error, close all connections to the database:
- Close pgAdmin
- Close any psql/pgcli sessions connected to `datawarehouse`
- Then retry

### Permission denied

Ensure you're using a superuser account (like `postgres`) or a user with `CREATEDB` privilege:
```
-- Check your privileges
SELECT current_user, 
       usecreatedb 
FROM pg_user 
WHERE usename = current_user;
```
