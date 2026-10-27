# Olist E-Commerce Data Pipeline

An end-to-end ELT pipeline that loads the Olist e-commerce dataset from AWS S3 into Snowflake, cleans and deduplicates it with dbt, and serves a star schema (facts and dimensions) plus business reports for analytics.

**Stack:** AWS S3 · Snowflake · dbt Core · SQL · Git/GitHub

---

## Problem Statement

Olist generates large volumes of order, payment, delivery, and review data, but it is scattered across 8 raw tables with duplicates and inconsistent grains. Teams struggle to:

- Spot delays in the order-to-delivery process
- Understand customer buying and payment behavior
- Track satisfaction through reviews and ratings
- Compare seller and product performance across regions

This project builds a reliable, tested analytics layer that answers those questions.

### Source ERD
<img width="583" height="372" alt="my raw schema" src="https://github.com/user-attachments/assets/7fd54541-9542-49f9-b553-8487152c3e98" />

---

## Architecture

```
AWS S3 (CSV files)
      │  COPY INTO (+ source_file_name, ingestion_timestamp)
      ▼
BRONZE        raw tables, duplicates allowed
      │  dbt
      ▼
STAGING       rename, cast types, standardize columns
      │  dbt
      ▼
INTERMEDIATE  deduplication (incremental merge on business key)
      │  dbt
      ▼
GOLD          star schema (facts + dimensions) and reports
```

Staging and intermediate together form the **Silver** layer.

| Layer | Schema | Materialization | Purpose |
|---|---|---|---|
| Bronze | `[BRONZE_RAW]` | table | Raw copy of S3 files with load metadata |
| Staging | `[STAGING]` | view | Cleaning, typing, column ordering |
| Intermediate | `[INTERMEDIATE]` | incremental (merge) | One row per business key |
| Gold | `[GOLD]` | table / view | Facts, dimensions, reports |

---

## Dataset

8 interrelated tables covering the full order lifecycle.

| Table | Description |
|---|---|
| `orders` | Orders, status, and timestamps |
| `order_items` | Line items with price and freight |
| `order_payments` | Payment transactions and methods |
| `order_reviews` | Review scores and comments |
| `customers` | Customer details and location |
| `products` | Product catalog, category, and dimensions |
| `sellers` | Seller details and location |
| `product_category_translation` | Portuguese to English category names |

**Source:** [Kaggle: Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## What I Built

### 1. Bronze: audit columns on every table
Every raw table loaded with `COPY INTO` now carries two extra columns:

| Column | Source | Purpose |
|---|---|---|
| `source_file_name` | `METADATA$FILENAME` | Traces each row to its S3 file |
| `ingestion_timestamp` | load time | Orders duplicates so the newest version wins, and acts as the incremental watermark |

### 2. Staging: typed and standardized
- All currency and value columns cast to fixed-point `NUMBER` to avoid floating-point precision errors
- Columns reordered to follow dbt style: **ids, then text, then numeric**
- Renaming and casting only, with no business logic

### 3. Intermediate: deduplication
Each table is reduced to one row per business key, keeping the most recently loaded version:

```sql
select *
from {{ ref('stg_customers') }}
qualify row_number() over (
    partition by customer_id
    order by ingestion_timestamp desc, source_file_name desc
) = 1
```

- The file name is a tie-breaker, so results are deterministic and reruns give the same output
- Models load as **incremental merge** on the business key, so reruns update rows instead of duplicating them

| Table | Grain (business key) |
|---|---|
| orders | `order_id` |
| customers | `customer_id` |
| order_items | `order_id`, `order_item_id` |
| order_payments | `order_id`, `payment_sequential` |
| order_reviews | `[review_id, order_id]` |
| products | `product_id` |
| sellers | `seller_id` |

### 4. Data quality tests
dbt tests run with `dbt build`, which skips downstream models when a test fails.

- `unique` and `not_null` on keys after deduplication
- `unique_combination_of_columns` on composite keys
- `not_null` on `ingestion_timestamp`, since a NULL would silently drop rows from incremental filters
- `relationships` from facts to dimensions

### 5. Gold: star schema with genuine grain
Every model declares its grain, and facts are kept at the grain of their source events instead of being pre-joined.

**Dimensions**

| Model | Grain |
|---|---|
| `dim_customers` | One row per `customer_id` |
| `dim_products` | One row per `product_id`, with English category name |
| `dim_sellers` | One row per `seller_id` |
| `dim_date` | One row per calendar day |

**Facts**

| Model | Grain |
|---|---|
| `fct_orders` | One row per order |
| `fct_items` | One row per order item (`order_id` + `order_item_id`) |
| `fct_payments` | One row per payment (`order_id` + `payment_sequential`) |
| `fct_reviews` | One row per review |

**Reports**

| Model | Grain | Answers |
|---|---|---|
| `rpt_monthly_summary` | One row per month | Revenue, delivery performance, and satisfaction trends |
| `rpt_cat_performance` | One row per product category | Which categories drive revenue |

---

## Design Decisions

- **Revenue = sum of item price**, excluding `canceled` and `unavailable` orders. The rule is defined once and reused by every report.
- **Customers are counted by `customer_unique_id`.** In this dataset `customer_id` is generated per order, so counting it would treat repeat buyers as new customers.
- **Aggregate before joining.** Items, payments, and reviews each have many rows per order, so reports aggregate them to order grain before joining. Joining raw would multiply rows and inflate sums.
- **Late delivery is NULL for undelivered orders**, so averages only cover delivered orders.
- **Category revenue uses item price, not payment totals**, since one order can contain items from several categories.
- **Gold holds current state only.** If a customer's city changed at the source, historical rows would show the new value.

---

## Project Structure

```
Olist_DataPipeline/
├── Dataset/                        # Raw source CSV files
├── dbt_workspace/
│   ├── macros/
│   │   └── generate_schema_name.sql
│   ├── models/
│   │   ├── staging/                # Silver: cleaning and typing
│   │   │   ├── stg_customers.sql
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_order_items.sql
│   │   │   ├── stg_order_payments.sql
│   │   │   ├── stg_order_reviews.sql
│   │   │   ├── stg_products.sql
│   │   │   ├── stg_sellers.sql
│   │   │   ├── stg_product_category_translation.sql
│   │   │   └── sources.yml
│   │   │
│   │   ├── intermediate/           # Silver: deduplication
│   │   │   ├── customers_dedup.sql
│   │   │   ├── order_items_dedup.sql
│   │   │   ├── order_reviews.sql
│   │   │   ├── orders.sql
│   │   │   ├── products_dedup.sql
│   │   │   ├── sellers_dedup.sql
│   │   │   └── intermediate.yml
│   │   │
│   │   └── marts/                  # Gold: star schema and reports
│   │       ├── dim_customers.sql
│   │       ├── dim_date.sql
│   │       ├── dim_products.sql
│   │       ├── dim_sellers.sql
│   │       ├── fct_items.sql
│   │       ├── fct_orders.sql
│   │       ├── fct_payments.sql
│   │       ├── fct_reviews.sql
│   │       ├── rpt_cat_performance.sql
│   │       ├── rpt_monthly_summary.sql
│   │       └── mart_models.yml
│   │
│   ├── test/
│   │   └── quality_check.yml
│   │
│   ├── dbt_project.yml
│   └── profiles.yml
├── snowflake_workspace/            # Snowflake setup scripts
│   ├── catalog_setup.sql
│   └── table_creation_&_ingestion.sql
└── README.md
```

---

## How to Run

```bash
# 1. In Snowflake, run the scripts in snowflake_workspace/ to create objects and load Bronze
# 2. Install dbt packages
dbt deps

# 3. Build and test all models
dbt build

# 4. Generate docs and lineage graph
dbt docs generate && dbt docs serve
```

Running `dbt build` twice in a row should leave row counts unchanged. That is the idempotency check.

---

## Known Limitations

Deferred mainly because of Snowflake compute credit limits on a self-funded account.

| Not implemented | How I would add it |
|---|---|
| CDC | Snowflake stream on Bronze with a task-driven merge |
| SCD Type 2 | dbt snapshots with `valid_from` / `valid_to` on customers, sellers, and products |
| Incremental gold models | Merge on the fact grain with a watermark and lookback window |
| `ON_ERROR = 'CONTINUE'` in `COPY INTO` | Switch to `ABORT_STATEMENT` or `SKIP_FILE`, and check `COPY_HISTORY` for rejected rows |

## Future Developments

- CI/CD with state-based `dbt build` on pull requests
- Monitoring with dbt artifacts and source freshness checks
- SCD Type 2 and CDC, as above
- Scheduling and orchestration beyond the dbt CLI

---

## What I Learned

- Defining the grain of every model first prevents most join errors
- Incremental loading is about efficiency, while idempotency is about safety
- Deduplication removes bad rows, and tests prove it worked
- Business definitions such as "revenue" and "customer" need agreement before modeling