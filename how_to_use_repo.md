# How to Use This Repository

## Requirements

- **PostgreSQL**: Version 16 or higher
- **Operating System**: macOS, Linux, or Windows (with PostgreSQL installed)
- **Privileges**: Access to a PostgreSQL user with database creation privileges (e.g., the `postgres` superuser)
- **Git**: For cloning the repository

## Installation and Setup

### 1. Install PostgreSQL

- **On macOS** (using Homebrew):
  ```
  brew install postgresql
  brew services start postgresql
  ```

- **On Ubuntu/Debian**:
  ```
  sudo apt update
  sudo apt install postgresql postgresql-contrib
  sudo systemctl start postgresql
  ```

- **On Windows**: Download and install from the [official PostgreSQL website](https://www.postgresql.org/download/).

- **Verify Installation**:
  ```
  psql --version
  ```

### 2. Clone the Repository

```
git clone https://github.com/davisjanis/postgresql-data-warehouse-project.git
cd postgresql-data-warehouse-project
```

### 3. Prepare the Dataset Files

When using the COPY command to load CSV files, PostgreSQL requires read access 
to the file system location where the CSV files are stored. You may encounter 
permission errors such as:

    ERROR: could not open file "/path/to/file.csv" for reading: 
    Permission denied

PostgreSQL runs under a specific user account ('postgres') that may 
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

- **Alternative Locations**:
  - If using Homebrew PostgreSQL: `/usr/local/var/postgres/datasets/`
  - If you encounter permission issues, adjust the paths in `scripts/bronze/func_load_bronze.sql` to match your setup.
  - Ensure the PostgreSQL user has read access to the directory.

### 4. Create the Database and Schemas

Run the initial setup scripts using `psql` (or `pgcli` if preferred).

- **Create the Database**:
  ```
  psql -U postgres -d postgres -f scripts/01_create_database.sql
  ```
  This creates a new database named `datawarehouse` (dropping it first if it exists).

- **Create the Schemas**:
  ```
  psql -U postgres -d datawarehouse -f scripts/02_create_schemas.sql
  ```
  This creates the `bronze`, `silver`, and `gold` schemas.

- **Verify Setup**:
  ```
  psql -U postgres -d datawarehouse -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('bronze', 'silver', 'gold');"
  ```

## Loading Data Layers

Execute the scripts in the following order to build the data warehouse layers.

### Bronze Layer (Raw Data Ingestion)

1. **Create Bronze Tables**:
   ```
   psql -U postgres -d datawarehouse -f scripts/bronze/ddl_bronze.sql
   ```

2. **Load Data into Bronze**:
   ```
   psql -U postgres -d datawarehouse -c "SELECT bronze.load_bronze();"
   ```
   This function loads CSV data into the bronze tables using `COPY` commands.

3. **Optional: Run Quality Checks**:
   ```
   psql -U postgres -d datawarehouse -f tests/quality_checks_silver_before_load.sql
   ```
   (Note: This script is named for silver but can be adapted for bronze checks.)

### Silver Layer (Data Cleaning and Standardization)

1. **Create Silver Tables**:
   ```
   psql -U postgres -d datawarehouse -f scripts/silver/ddl_silver.sql
   ```

2. **Load Data into Silver**:
   ```
   psql -U postgres -d datawarehouse -c "SELECT silver.load_silver();"
   ```
   This function transforms and cleans data from bronze into silver tables.

3. **Run Quality Checks**:
   ```
   psql -U postgres -d datawarehouse -f tests/quality_checks_silver_after_load.sql
   ```

### Gold Layer (Business-Ready Views)

1. **Create Gold Views**:
   ```
   psql -U postgres -d datawarehouse -f scripts/gold/ddl_gold.sql
   ```
   This creates dimension and fact views for analytics.

2. **Verify Gold Layer**:
   ```
   psql -U postgres -d datawarehouse -f tests/building_gold_layer.sql
   ```
   This script demonstrates the view creation process.

## Usage and Analytics

- **Query the Gold Layer**: Use the views in the `gold` schema for reporting and analytics.
- **Example Query**:
  ```
  psql -U postgres -d datawarehouse -c "SELECT * FROM gold.dim_customers LIMIT 10;"
  ```
- **Data Catalog**: Refer to `docs/data_catalog.md` for detailed descriptions of gold layer tables and columns.

## Troubleshooting

- **Permission Errors**: Ensure the PostgreSQL user can read the CSV files. Adjust file paths or permissions as needed.
- **Database Connection Issues**: Verify PostgreSQL is running and you have the correct username/password.
- **Script Failures**: Check PostgreSQL logs for errors. Ensure all prerequisites are met.
- **Dropping Database**: Script `01_create_database.sql` drops the existing `datawarehouse` database. Back up data if necessary.

## Additional Notes

- The project uses stored functions for loading to ensure consistency and logging.
- Quality checks are provided to validate data at each stage.
- For production use, consider security, backups, and performance tuning.
