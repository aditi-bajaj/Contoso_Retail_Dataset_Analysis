/*
Product Revenue Concentration Analysis (Pareto 80/20)
or
Category-Level Revenue Distribution Analysis
Top Products Driving Category Revenue
For each category:
Determine the minimum number of products required to generate 50% of category revenue
Identifies the smallest group of products responsible for at least 50% of each category's total revenue
*/

WITH
facts
AS(
    SELECT
        p.categoryname AS product_category,
        p.productkey AS product_key,
        p.productname AS product_name,
        SUM(s.quantity * s.netprice / s.exchangerate) AS product_revenue
    FROM
        product p
    JOIN sales s ON s.productkey = p.productkey
    GROUP BY
        product_category,
        product_key,
        product_name
),
revenue
AS(
    SELECT *,
        ROW_NUMBER() OVER(
            PARTITION BY product_category
            ORDER BY product_revenue DESC
        ) AS count,
        SUM(product_revenue) OVER(
            PARTITION BY product_category
            ORDER BY product_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_product_revenue,
        SUM(product_revenue) OVER(PARTITION BY product_category) AS total_category_revenue
    FROM
        facts f
),
main
AS(
    SELECT *,
        cumulative_product_revenue / total_category_revenue AS cumulative_pct,
        COUNT(*) OVER(PARTITION BY product_category) AS total_products
    FROM
        revenue r
),
pareto
AS(
    SELECT
        product_category,
        MIN(count) AS products_for_80pct_revenue,
        total_products,
        ROUND((100.0* MIN(count) / total_products) , 2) AS pct_of_products
    FROM
        main m
    WHERE
        cumulative_pct >= 0.8 
    GROUP BY
        product_category,
        total_products
)
SELECT *,
    CASE
        WHEN pct_of_products < 35 THEN 'Highly Concentrated'
        WHEN pct_of_products BETWEEN 35 AND 45 THEN  'Moderate Concentration'
        ELSE 'Distributed Revenue'
        END AS revenue_distribution
FROM
    pareto p
ORDER BY
    pct_of_products