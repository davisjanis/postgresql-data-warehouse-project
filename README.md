# PostgreSQL Data Warehouse and Analytics Project

Welcome to the **PostgreSQL Data Warehouse and Analytics Project** repository.

This project demonstrates how to build a data warehouse from scratch - transforming raw, sometimes messy data from multiple systems into clean, structured, and analytics-ready datasets. Unlike operational databases built for day-to-day transactions, a data warehouse is optimized for historical analysis and reporting — giving businesses a reliable foundation for data-driven decisions.

<img width="1258" height="683" alt="Medallion1 drawio" src="https://github.com/user-attachments/assets/11140583-0607-4e7a-a7c4-7944d277e64e" />

---
# Data Architecture

The data architecture for this project follows Medallion Architecture - having Bronze, Silver, and Gold layers:

Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into PostgreSQL database.

Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.

Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics. 

---
# Project Overview

If you want to gain basic understanding of data engineering foundations with SQL, this repository is for you.
Use it together with my Notion site, to get deeper details about each project's phase.
This project is mostly based on this [repository](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main), but adjusted for the PostgreSQL database with additional information about intermediate steps.


This project involves:

1. **Data Architecture**: Designing a modern data warehouse using Medallion Architecture - having Bronze, Silver, and Gold layers.
2. **ELT Pipeline**: Extracted datasets from source systems, loading and transforming them into the data warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

**Important Notice about - why ELT instead of ETL?**

Someone just getting into the field of data engineering, and having some familiarity with core concepts and definitions - might raise the question, could this project represent ETL pipeline instead of ELT?

The answer is: 
Depends on perspective.

To clarify: 
The Medallion architecture inside a single database sits in a grey zone, and whether you call it ETL or ELT depends on where you draw the system boundary.

Perspective: 

Some practitioners and architects describe the Medallion architecture as
- Bronze = landing / staging zone ( the "load" of raw data )
- Silver = transformation
- Gold = the final load into the serving layer for consumers

Under this view, Gold is the true destination, and everything before it is preparation. So the pipeline reads as ETL - you're transforming before delivering the final, loaded, business-ready data.

The reason why I see ELT is the more dominant label for this project:
Because the entire transformation chain - Bronze -> Silver -> Gold - happens inside the same database engine. There's no external transformation tool. PostgreSQL is doing all the work throughout. 

Takeaway:
ETL vs ELT as labels were coined before the Medallion architecture existed. They don't map perfectly onto it. In practice, most data engineers working with bronze/silver/gold inside a single database call it ELT - but if someone calls it ETL focusing on the gold layer as the destination, they're not wrong either.
   
---
# Important Links

- [Notion](https://celestial-badge-693.notion.site/Data-Warehouse-Project-2fd6c23abbb480d78ac0e2782481840a?pvs=74): Personal Notion site for this project management, also includes more detailed explanations on some project phases.
- [Data With Baraa](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main) This project is based on the repository from Baraa Khatib Salkini. So, big thanks to him and check his [Youtube](https://www.youtube.com/@DataWithBaraa) content!


## Project Requirements

- Familiarity with SQL language
- Datasets — source CSV files (provided in /datasets folder of this repository)
- PostgreSQL 16+ — database engine
- pgAdmin 4 — GUI for database management and query execution
  
OR, if you prefer working solely from terminal:

- psql command-line tools (comes with PostgreSQL installation) - a command line interface for running SQL queries
     - Add PostgreSQL to the system PATH to ensure the psql is globally                            accessible for local CSV ingestion via the \copy command
- pgcli (optional) - a command line interface with auto-completion and syntax highlighting
      - Same here, ensure that pgcli is globally accessible in your PATH


### Building the Data Warehouse

For detailed information how to recreate this data warehouse on your system use the following [documentation](https://github.com/davisjanis/postgresql-data-warehouse-project/blob/main/how_to_use_repo.md)

### Objective

Develop a modern data warehouse using PostgreSQL to consolidate sales data, enabling analytical reporting and informed decision-making.

### Specifications

- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

### Objective

Develop SQL-based analytics to deliver detailed insights into:

- **Customer Behavior**
- **Product Performance**
- **Sales Trends**
  
These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## License

This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.
