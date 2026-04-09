WITH monthly_sales
AS(
    SELECT
        DATE_TRUNC('MONTH', s.orderdate)::DATE AS month,
        SUM(s.quantity * s.netprice / s.exchangerate)::NUMERIC AS total_sales
    FROM
        sales s
    GROUP BY
        month
),
mom_sales
AS(
SELECT *,
    100* (total_sales - LAG(total_sales) OVER(ORDER BY month)) 
                / LAG(total_sales) OVER(ORDER BY month) AS mom_change
FROM
    monthly_sales ms
),
ranked_sales
AS(
    SELECT *,
        DENSE_RANK() OVER(ORDER BY mom_change DESC) AS rank
    FROM
        mom_sales
    WHERE
        mom_change IS NOT NULL
)
SELECT
    TO_CHAR(month, 'Month YYYY') AS month,
    ROUND(mom_change , 2) AS mom_growth_pct
FROM
    ranked_sales rs
WHERE
    rs.rank BETWEEN 1 AND 10