-- Choosing DATABASE
use database e_commerce
;

-- Create orders table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);

COPY INTO E_COMMERCE.BRONZE_RAW.orders (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    source_file_name,
    ingestion_timestamp
)
FROM (
    SELECT
        $1, $2, $3, $4, $5, $6, $7, $8,
        METADATA$FILENAME,
        SYSDATE()
    FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/orders'
)
FILE_FORMAT = (
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create customers table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(20),
    customer_city VARCHAR(100),
    customer_state VARCHAR(5),
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.customers(
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    source_file_name,
    ingestion_timestamp
)

FROM (
  SELECT  $1, $2, $3, $4, $5, METADATA$FILENAME, SYSDATE()
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/customers'
)
FILE_FORMAT = (
  TYPE = 'CSV' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create order_items table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(12,2),
    freight_value DECIMAL(12,2),
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.order_items (
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value,
    source_file_name,
    ingestion_timestamp
)
FROM (
  SELECT $1, $2, $3, $4, $5, $6, $7, METADATA$FILENAME, SYSDATE()
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/order_items'
)
FILE_FORMAT = (
  TYPE = 'CSV' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create order_payements table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value DECIMAL(12,2),
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.order_payments (
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    source_file_name,
    ingestion_timestamp
)
FROM (
  SELECT $1, $2, $3, $4, $5, METADATA$FILENAME, SYSDATE()
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/order_payments'
)
FILE_FORMAT = (
  TYPE = 'CSV' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create order_review table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title VARCHAR(255),
    review_comment_message VARCHAR(2000),
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.order_reviews (
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    source_file_name,
    ingestion_timestamp
)
FROM (
SELECT $1, $2, $3, $4, $5, $6, $7, METADATA$FILENAME, SYSDATE()
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/order_reviews'
)
FILE_FORMAT = (
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create products table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER,
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.products (
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    source_file_name,
    ingestion_timestamp
)
FROM (
SELECT $1, $2, $3, $4, $5, $6, $7, $8, $9, METADATA$FILENAME, SYSDATE()
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/products'
)
FILE_FORMAT = (
  TYPE = 'CSV' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create Sellers table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.sellers (
    seller_id VARCHAR(50),
    seller_zip_code_prefix VARCHAR(20),
    seller_city VARCHAR(100),
    seller_state VARCHAR(5),
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.sellers (
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    source_file_name,
    ingestion_timestamp
)
FROM (
SELECT $1, $2, $3, $4, METADATA$FILENAME, SYSDATE()
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/sellers'
)
FILE_FORMAT = (
  TYPE = 'CSV' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '"' 
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';

-- Create PCNT Table and ingest into it
CREATE OR REPLACE TABLE E_COMMERCE.BRONZE_RAW.product_category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    source_file_name VARCHAR(500),
    ingestion_timestamp TIMESTAMP_NTZ
);
COPY INTO E_COMMERCE.BRONZE_RAW.product_category_translation (
    product_category_name,
    product_category_name_english,
    source_file_name,
    ingestion_timestamp
)
FROM (
SELECT $1, $2, METADATA$FILENAME, SYSDATE() 
FROM '@E_COMMERCE.STG.s3_con/raw(bronze)/product_category_name_translation'
)
FILE_FORMAT = (
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  FIELD_DELIMITER = ','
)
ON_ERROR = 'CONTINUE';
