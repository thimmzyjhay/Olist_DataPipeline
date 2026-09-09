-- Database and Schema setup with roles
CREATE DATABASE IF NOT EXISTS e_commerce;
CREATE SCHEMA bronze_raw;
grant usage
on schema bronze_raw
to role etl_role
;
grant create table
on schema bronze_raw
to role etl_role
;
grant select, insert
on future tables in schema bronze_raw
to role etl_role
;
grant select, insert
on all tables in schema bronze_raw
to role etl_role
;

CREATE ROLE IF NOT EXISTS ETL_ROLE;
grant usage
on warehouse compute_wh
to role etl_role
;
grant usage
on database e_commerce
to role etl_role
;
grant create table
on schema e_commerce.bronze_raw
to role etl_role
;
grant select, insert
on future tables in schema e_commerce.bronze_raw
to role etl_role
;
grant select, insert
on all tables in schema e_commerce.bronze_raw
to role etl_role
;

-- creating snowflake user for glue
CREATE USER IF NOT EXISTS glue_user 
    PASSWORD = 'xxxxxxxxxxx'
    DEFAULT_ROLE = ETL_ROLE
    DEFAULT_WAREHOUSE = compute_wh
    DEFAULT_NAMESPACE = e_commerce.bronze_raw
    COMMENT = 'Service account for AWS Glue and other connection on ETL';

grant role etl_role
to user glue_user
;

-- Classify glue_user as a programmatic service account to exempt it from MFA
ALTER USER glue_user SET TYPE = SERVICE;
ALTER USER glue_user SET PASSWORD = 'xxxxxxxxxxxxxxxxx';
