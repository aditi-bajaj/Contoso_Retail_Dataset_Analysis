SELECT
    s.orderdate AS order_date,
    COUNT( DISTINCT
        CASE WHEN c.continent = 'Australia' THEN s.customerkey END) AS au_customers,
    COUNT( DISTINCT
        CASE WHEN c.continent = 'Europe' THEN s.customerkey END) AS eu_customers,
    COUNT( DISTINCT
        CASE WHEN c.continent = 'North America' THEN s.customerkey END) AS na_customers
FROM
    sales s
LEFT JOIN customer c ON c.customerkey = s.customerkey
WHERE
    orderdate::DATE BETWEEN '2023-01-01'AND '2023-12-31'
GROUP BY
    s.orderdate
ORDER BY
    order_date