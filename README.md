# Olist Ecommerce Pipeline

## Project Overview

This project implements the design and deployment of an end‑to‑end data engineering pipeline using **the Olist OLTP dataset**.  
Raw transactional data is ingested from **AWS S3** into a **Snowflake warehouse**, then transformed with **dbt** into analytics ready tables for reporting and advanced analytics.
The objective is to convert raw operational data into a scalable analytical warehouse that supports business intelligence and data science use cases.

### Source ERD
<img width="583" height="372" alt="my raw schema" src="https://github.com/user-attachments/assets/7fd54541-9542-49f9-b553-8487152c3e98" />

## Problem Statement
Brazil's e‑commerce sector has grown rapidly, but companies face challenges in understanding customer behavior, logistics performance, and satisfaction drivers. The Olist dataset captures over a decade of transactions from a major Brazilian marketplace. The problem is that without integration and analysis, businesses cannot:
- Identify bottlenecks in delivery times and freight costs.
- Understand payment patterns and customer preferences.
- Track customer satisfaction through reviews and ratings.
- Evaluate seller and product performance across regions.

## Project Architecture
The pipeline demonstrates the architecture of a modern cloud native data stack, including:
- **Cloud Data Lake storage** (AWS S3)  
- **Cloud Data Warehouse** (Snowflake)  
- **dbt‑based transformations** for ELT  
- **Dimensional modelling** (star schema design)   
- **Workflow orchestration** (via dbt CLI)  
- **Business Intelligence enablement** (analytics ready marts)


## Key concepts demonstrated in this project include:
- OLTP → OLAP transformation  
- Dimensional modelling and star schema design  
- Modern ELT architecture with dbt  
- Cloud native ingestion and transformation pipeline

## Dataset
Tables included:
- **orders** – customer orders
- **order_items** – items within each order
- **customers** – customer details
- **products** – product catalog
- **sellers** – seller information
- **order_reviews** – customer reviews
- **order_payments** – payment transactions
- **product_category_translation** – product category mapping

## Tech Stack
- Warehouse: **Snowflake**
- Transformation: **dbt**
- Version control: **Git + GitHub**
- Orchestration: **dbt CLI** (local runs)
- Documentation: **github**

## ELT Process

- **Extract**: Raw e‑commerce data is ingested from **AWS S3** into the data pipeline.  
- **Load**: The extracted data is loaded into the **Snowflake warehouse** under the `E_COMMERCE.BRONZE` schema.  
- **Transform**: Using **dbt**, transformations are executed directly inside Snowflake:  
  - **Staging models (SILVER)** standardize formats, clean data, and apply business rules.  
  - **Mart models (GOLD)** aggregate data into dimensional structures for analytics and reporting.  

**Flow:** **AWS S3 → Snowflake (Bronze) → dbt (Silver) → dbt (Gold)**

## Transformations
- **Models**: SQL models define transformations from raw data into staging and analytics layers.  
- **Macros**: custom logic for schema renaming and materialization strategies.  
- **Configuration**: managed through `dbt_project.yml` to control project settings and model behavior.  
- **Profiles**: connection details stored in `profiles.yml` for Snowflake warehouse access.  
- **Version Control**: Git was used to track changes, manage branches, and maintain project history.  
- **Repository Management**: `.gitignore` ensures clean repository organization by excluding unnecessary files.

## File structure
```
Olist_Dataset
├── Dataset/
├── dbt/
│   ├── macros/
│   └── models/
│       ├── marts/
│       │   ├── dimensions/
│       │   └── facts/
│       └── staging/
├── Snowflake_Workspace/
└── README.md
```

## Future Developments
- CI/CD integration.
- Monitoring with dbt artifacts.
- Scaling incremental models.
- SCD type 2 implementation.
