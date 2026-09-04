/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors.

Highlights:
    1. Gathers essential customer and transaction fields.
    2. Segments customers by age and spending behavior.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products purchased
        - lifespan
    4. Calculates KPIs:
        - recency
        - average order value
        - average monthly spend
===============================================================================
*/

CREATE OR ALTER VIEW gold.report_customers AS

WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(
            c.first_name,
            ' ',
            c.last_name
        ) AS customer_name,
        DATEDIFF(
            YEAR,
            c.birthdate,
            GETDATE()
        ) AS age

    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key

    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS (
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order,

        DATEDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan

    FROM base_query

    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,

    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        ELSE '60 and Above'
    END AS age_group,

    CASE
        WHEN lifespan >= 12
             AND total_sales > 5000
            THEN 'VIP'

        WHEN lifespan >= 12
             AND total_sales <= 5000
            THEN 'Regular'

        ELSE 'New'
    END AS customer_segment,

    total_orders,
    total_sales,
    total_quantity,
    total_products,

    DATEDIFF(
        MONTH,
        last_order,
        GETDATE()
    ) AS recency,

    lifespan,

    -- Average order value
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE CAST(total_sales AS DECIMAL(18,2))
             / total_orders
    END AS avg_order_value,

    -- Average monthly spend
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE CAST(total_sales AS DECIMAL(18,2))
             / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;

GO
