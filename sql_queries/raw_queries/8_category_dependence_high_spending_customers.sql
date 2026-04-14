/*
Category Dependence on High-Spending Customers:
Identifies the revenue dependence of each product category on the top 10% of its customers
*/

WITH
revenue
AS(
    SELECT
        p.categoryname AS product_category,
        s.customerkey AS customer_key,
        SUM(s.quantity * s.netprice / s.exchangerate)::NUMERIC AS customer_revenue,
        SUM(SUM(s.quantity * s.netprice / s.exchangerate)::NUMERIC) OVER(PARTITION BY p.categoryname) AS total_revenue
    FROM
        sales s
    JOIN product p ON p.productkey = s.productkey
    GROUP BY
        product_category,
        customer_key
),
percentile
AS(
    SELECT
        product_category,
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY customer_revenue) AS p90th
    FROM
        revenue r
    GROUP BY
        product_category
)
SELECT
    r.product_category,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(SUM(customer_revenue), 2) AS top_10_pct_customers_revenue,
    ROUND((100* SUM(customer_revenue) / total_revenue) ,2) AS pct_dependence
FROM
    revenue r
JOIN percentile pt ON pt.product_category = r.product_category
WHERE
    customer_revenue > p90th
GROUP BY
    r.product_category,
    total_revenue
ORDER BY
    pct_dependence DESC