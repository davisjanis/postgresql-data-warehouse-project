# PostgreSQL Data Warehouse and Analytics Project

Welcome to the **PostgreSQL Data Warehouse and Analytics Project** repository.

This project demonstrates a data warehouse and analytics solution with PotgreSQL, from building a data warehouse to generating actionable insights. 

---
# Data Architecture
--
The data architecture for this project follows Medallion Architecture - having Bronze, Silver, and Gold layers:
<img width="1134" height="633" alt="Medallion-3" src="https://github.com/user-attachments/assets/1a062ff4-6c2d-4861-985d-abae76a80787" />

Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into PostgreSQL database.
Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics. 

---
# Project Overview
--

If you want to gain basic understanding of Data Engineering foundations with SQL, this repository is for you.
Use it together with my Notion site, to get deeper details about each project's phase.
This project is mostly based on this [repository](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main), but adjusted for the PostgreSQL database.

--
This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse using Medallion Architecture - having Bronze, Silver, and Gold layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the data warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.
   
---
# Important Links

- [Notion](https://celestial-badge-693.notion.site/Data-Warehouse-Project-2fd6c23abbb480d78ac0e2782481840a?pvs=74): Personal Notion site for this project management, also includes more detailed explanations on some project phases.
- [Data With Baraa](https://github.com/DataWithBaraa/sql-data-warehouse-project/tree/main) This project is based on the repository from Baraa Khatib Salkini. So, big thanks to him and check his [Youtube](https://www.youtube.com/@DataWithBaraa) content!


## Project Requirements

- Familiarity with SQL language
- PostgreSQL 16+ — database engine
- pgAdmin 4 — GUI for database management and query execution
- Dataset — source CSV files (provided in /datasets folder of this repository)
- PostgreSQL configured with correct file paths — required for COPY command to ingest CSV files into bronze layer:

### Building the Data Warehouse (Data Engineering)

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
