/*
Category Contribution to Company Revenue: Calculates the following for each product category-
- category revenue
- percentage contribution to total company revenue
- rank categories by contribution
*/

WITH
facts
AS(
    SELECT
        p.categoryname AS product_category,
        SUM(s.quantity * s.netprice / s.exchangerate) AS category_revenue,
        SUM(SUM(s.quantity * s.netprice / s.exchangerate)) OVER() AS total_company_revenue
    FROM
        sales s
    JOIN product p ON p.productkey = s.productkey
    GROUP BY
        product_category
),
revenue
AS(
    SELECT
        product_category,
        ROUND(category_revenue::NUMERIC, 2) AS category_revenue,
        ROUND(total_company_revenue::NUMERIC, 2) AS total_company_revenue,
        (100* category_revenue / total_company_revenue)::INTEGER AS category_contribution_pct
    FROM
        facts
)
SELECT
    DENSE_RANK() OVER(ORDER BY category_contribution_pct DESC) AS rank,
    r.*
FROM
    revenue r