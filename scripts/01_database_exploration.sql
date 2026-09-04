/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - Explore database objects, columns, dimensions, and available data ranges.
===============================================================================
*/

-- Explore all objects in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- Explore columns in the customer dimension
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- Explore customer countries
SELECT DISTINCT
    country
FROM gold.dim_customers;

-- Explore product categories, subcategories, and products
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products;

-- Find the date range of available orders
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(
        YEAR,
        MIN(order_date),
        MAX(order_date)
    ) AS order_range_years
FROM gold.fact_sales;

-- Find oldest and youngest customers
SELECT
    MIN(birthdate) AS oldest_customer,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_customer,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
