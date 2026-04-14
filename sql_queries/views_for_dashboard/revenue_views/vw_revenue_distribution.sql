CREATE VIEW vw_revenue_distribution AS
WITH base AS (
    SELECT 
        EXTRACT(YEAR FROM s.orderdate) AS year,
        p.categoryname AS product_category,
        s.quantity * s.netprice / s.exchangerate AS net_revenue
    FROM sales s
    JOIN product p ON p.productkey = s.productkey
),
median_calc AS (
    SELECT 
        product_category,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY net_revenue) AS median_value
    FROM base
    GROUP BY product_category
)
SELECT 
    b.year,
    b.product_category,
    CASE 
        WHEN b.net_revenue < m.median_value THEN 'Low'
        ELSE 'High'
    END AS revenue_group,
    SUM(b.net_revenue) AS total_revenue
FROM base b
JOIN median_calc m 
    ON b.product_category = m.product_category
GROUP BY b.year, b.product_category, revenue_group;