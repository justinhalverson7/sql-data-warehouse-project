/*
===============================================================================
Measures and KPIs
===============================================================================
Purpose:
    - Calculate high-level business metrics from the sales data.
===============================================================================
*/

-- Find total sales
SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find total quantity sold
SELECT
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Find average selling price
SELECT
    AVG(price) AS average_price
FROM gold.fact_sales;

-- Find total number of orders
SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Find total number of products
SELECT
    COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;

-- Find total number of customers
SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;

-- Find total number of customers who placed an order
SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;
