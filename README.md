# Olist Ecommerce DataPipeline

## Project Overview

This project implements the design and deployment of an end‑to‑end data engineering pipeline using **the Olist OLTP dataset**.
Raw transactional data is ingested from **AWS S3** into a **Snowflake warehouse**, then transformed with **dbt** into analytics ready tables for reporting and advanced analytics.
The objective is to centralize raw operational data into a reliable analytics layer that improves visibility, reporting, and decision making across the organization and also reduces manual reporting effort and gives teams timely access to business insights.

### Source ERD
<img width="583" height="372" alt="my raw schema" src="https://github.com/user-attachments/assets/7fd54541-9542-49f9-b553-8487152c3e98" />

## Problem Statement
Olist e-commerce company generates large volumes of order, payment, delivery, and customer review data, but the data is often scattered and difficult to turn into actionable insight. As a result, teams struggle to identify delivery bottlenecks, understand what drives customer satisfaction, track payment behavior, and compare seller and product performance across regions.

Without a reliable data foundation, businesses cannot:
- Spot delays and inefficiencies in the order to delivery process.
- Understand customer buying and payment behavior.
- Monitor satisfaction trends from review and rating data.
- Evaluate seller and product performance to improve operations and growth.

## Project Architecture
The pipeline demonstrates the architecture of a modern cloud native data stack, including:
```
AWS S3 (Raw Files)
      │
      ▼
Snowflake – BRONZE Schema  (Raw ingestion layer)
      │
      ▼
Snowflake – SILVER Schema  (Staging: cleaned & standardized via dbt)
      │
      ▼
Snowflake – GOLD Schema    (Marts: dimensional models for analytics)
```
### Architecture Components
| Component | Tool |
|---|---|
| Cloud Storage | AWS S3 |
| Cloud Data Warehouse | Snowflake |
| Transformation Framework | dbt (ELT) |
| Data Modelling | Star Schema / Dimensional Modelling |
| Orchestration | dbt CLI |
| Version Control | Git + GitHub |


### Key Concepts Demonstrated
- OLTP → OLAP transformation
- Dimensional modelling and star schema design
- Modern ELT architecture with dbt
- Medallion Architecture (Bronze / Silver / Gold)
- Cloud-native ingestion and transformation pipeline
- Custom dbt macros for schema management

## Dataset
The Olist dataset consists of 8 interrelated tables representing the full e-commerce order lifecycle:
| Table | Description |
|---|---|
| `orders` | Customer orders and their status/timestamps |
| `order_items` | Line items within each order including price and freight |
| `customers` | Customer details and geolocation |
| `products` | Product catalog with category and dimensions |
| `sellers` | Seller information and location |
| `order_reviews` | Customer review scores and comments |
| `order_payments` | Payment transactions and methods |
| `product_category_translation` | Portuguese to English category name mapping |

**Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

### Tech Stack
| Layer | Technology |
|---|---|
| Cloud Storage | AWS S3 |
| Data Warehouse | Snowflake |
| Transformation | dbt Core |
| Language | SQL |
| Version Control | Git + GitHub |
| Orchestration | dbt CLI (local) |
| Documentation | dbt docs + GitHub |

## ELT Process

- **Extract**: Raw e‑commerce data is ingested from **AWS S3** into the data pipeline.  
- **Load**: The extracted data is loaded into the **Snowflake warehouse** under the `E_COMMERCE.BRONZE` schema.  
- **Transform**: Using **dbt**, transformations are executed directly inside Snowflake:  
   - **Staging models (SILVER)** standardize formats, clean data, and apply business rules.  
   - **Mart models (GOLD)** aggregate data into dimensional structures for analytics and reporting.  

**Flow:** **AWS S3 → Snowflake (Bronze) → dbt (Silver) → dbt (Gold)**

## Ingestion (Bronze)

**1. Catalog setup** — before loading any data, a database, schema, and role based access are created in Snowflake so raw data lands in a governed, permissioned location rather than an open free for all:


**2. Load** — raw CSVs are then loaded from **AWS S3** into `bronze_raw` using **COPY INTO**, via a configured file format and external stage. This solves the core ingestion problem: getting scattered files out of S3 and into a queryable warehouse table, with consistent load rules, before any transformation logic touches the data.

## Staging Layer (Silver)

Every staging model does the same two things to its raw Bronze table: **trims** whitespace from text fields and **casts** each column to its correct data type (e.g. IDs to `STRING`, dates to proper timestamp types). This solves the problem of raw data being unreliable to group, sum, or join on a `customer_id` with trailing spaces or a zip code silently cast to the wrong type will break joins and miscount records downstream, and this is the layer that guarantees that never happens.

## Marts Layer (Gold)

**Dimensions**
- `dim_customers` — which states have the most customers, and how much is repeat vs. unique?
- `dim_sellers` — which states have the most active sellers?
- `dim_products` — how big is each product category?
- `dim_orders` — what's our overall delivery performance?

**Facts**
- `fct_order_items` — what was each order worth, and how many items/sellers were involved?
- `fct_order_payments` — how was each order paid, and how many attempts did it take?
- `fct_order_reviews` — how satisfied was the customer, and what did they say?
- `fact_summary` — the full picture of one order (items + payment + review) in a single row.

## dbt Configuration (YAML)

Model behavior and documentation are managed through dbt's YAML files rather than hardcoded in SQL:

- **`profiles.yml`** — handles the Snowflake connection: account, warehouse, database, schema, and credentials. This is what lets `dbt run` actually reach the warehouse.
- **`dbt_project.yml`** — the project wide config: default materializations per folder (e.g. staging models as `table`, marts as `view`), model paths, and other settings that apply across the whole project rather than one model at a time.
- **`schema.yml`** (one inside each model folder staging, dimensions, facts) — documents each model and its columns, declares sources via `source()` so raw Bronze tables aren't hardcoded by name, and defines tests like `unique` and `not_null` on key columns so broken or duplicate data is caught automatically instead of surfacing later in a report.

Splitting configuration this way keeps connection details, project wide defaults, and model level documentation/tests each in their own place so a change to one (e.g. adding a test to `fct_order_payments`) doesn't require touching the others.

## dbt Project Structure

**Staging (Silver)**
| Model | Description |
|---|---|
| `stg_customers` | Cleaned customer records |
| `stg_orders` | Standardized order data |
| `stg_order_items` | Cleaned order line items |
| `stg_order_payments` | Normalized payment records |
| `stg_order_reviews` | Cleaned review scores and comments |
| `stg_products` | Standardized product catalog |
| `stg_sellers` | Cleaned seller records |
| `stg_product_category_translation` | Mapped category translations |

**Marts (Gold)**
*Dimensions:*
| Model | Description |
|---|---|
| `dim_customers` | Customer dimension |
| `dim_products` | Product dimension |
| `dim_sellers` | Seller dimension |
| `dim_orders` | Order dimension |

*Facts:*
| Model | Description |
|---|---|
| `fct_order_items` | Order items fact table |
| `fct_order_payments` | Payment transactions fact table |
| `fct_order_reviews` | Reviews and ratings fact table |
| `fact_summary` | Aggregated order summary |

## File structure
```
Olist_DataPipeline/
├── dbt_workspace/
│   ├── macros/
│   │   └── generate_schema_name.sql
│   ├── models/
│   │   ├── staging/                # Silver layer models
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_order_items.sql
│   │   │   ├── stg_order_payments.sql
│   │   │   ├── stg_order_reviews.sql
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_sellers.sql
│   │   │   ├── stg_product_category_translation.sql
│   │   │   └── sources.yml
│   │   └── marts/                    # gold layer models
│   │       ├── dimensions/
│   │       │   ├── dim_customers.sql
│   │       │   ├── dim_products.sql
│   │       │   ├── dim_sellers.sql
│   │       │   └── dim_orders.sql
│   │       └── facts/
│   │           ├── fct_order_items.sql
│   │           ├── fct_order_payments.sql
│   │           ├── fct_order_reviews.sql
│   │           └── fact_summary.sql
│   ├── dbt_project.yml
│   └── profiles.yml
├── snowflake_workspace/            # Snowflake setup scripts
└── README.md
```

## Future Developments
- CI/CD integration.
- Monitoring with dbt artifacts.
- Scaling incremental models.
- SCD type 2 implementation.
