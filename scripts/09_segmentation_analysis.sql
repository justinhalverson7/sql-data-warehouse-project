/*
===============================================================================
Segmentation Analysis
===============================================================================
Purpose:
    - Segment products based on cost.
    - Segment customers based on spending behavior and lifespan.
===============================================================================
*/


/*
-------------------------------------------------------------------------------
Product Cost Segmentation
-------------------------------------------------------------------------------
*/

WITH product_segment AS (
    SELECT
        product_key,
        product_name,
        cost,

        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range

    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;


/*
-------------------------------------------------------------------------------
Customer Segmentation

VIP:
    Customers with at least 12 months of history
    and more than $5,000 in spending.

Regular:
    Customers with at least 12 months of history
    and $5,000 or less in spending.

New:
    Customers with less than 12 months of history.
-------------------------------------------------------------------------------
*/

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spend,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(
            MONTH,
            MIN(f.order_date),
            MAX(f.order_date)
        ) AS lifespan

    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key

    GROUP BY c.customer_key
)

SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT
        customer_key,

        CASE
            WHEN lifespan >= 12
                 AND total_spend > 5000
                THEN 'VIP'

            WHEN lifespan >= 12
                 AND total_spend <= 5000
                THEN 'Regular'

            ELSE 'New'
        END AS customer_segment

    FROM customer_spending
) t

GROUP BY customer_segment
ORDER BY total_customers DESC;
