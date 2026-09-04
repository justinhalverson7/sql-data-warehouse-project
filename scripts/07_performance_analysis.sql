/*
===============================================================================
Performance Analysis
===============================================================================
Purpose:
    - Analyze yearly product performance.
    - Compare product sales against:
        1. The product's average yearly sales.
        2. The product's previous-year sales.
===============================================================================
*/

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,

    -- Compare against average product sales
    AVG(current_sales) OVER (
        PARTITION BY product_name
    ) AS avg_sales,

    current_sales -
    AVG(current_sales) OVER (
        PARTITION BY product_name
    ) AS diff_avg,

    CASE
        WHEN current_sales -
             AVG(current_sales) OVER (
                 PARTITION BY product_name
             ) > 0
            THEN 'Above Average'

        WHEN current_sales -
             AVG(current_sales) OVER (
                 PARTITION BY product_name
             ) < 0
            THEN 'Below Average'

        ELSE 'Average'
    END AS avg_change,

    -- Year-over-year analysis
    LAG(current_sales) OVER (
        PARTITION BY product_name
        ORDER BY order_year
    ) AS py_sales,

    current_sales -
    LAG(current_sales) OVER (
        PARTITION BY product_name
        ORDER BY order_year
    ) AS diff_py,

    CASE
        WHEN current_sales -
             LAG(current_sales) OVER (
                 PARTITION BY product_name
                 ORDER BY order_year
             ) > 0
            THEN 'Increase'

        WHEN current_sales -
             LAG(current_sales) OVER (
                 PARTITION BY product_name
                 ORDER BY order_year
             ) < 0
            THEN 'Decrease'

        ELSE 'No Change'
    END AS py_change

FROM yearly_product_sales
ORDER BY
    product_name,
    order_year;
