WITH
customer_ltv
AS(
    SELECT
        customerkey,
        SUM(total_net_revenue) AS ltv
    FROM
        cohort_analysis ca
    GROUP BY
        customerkey
),
pareto_table
AS(
    SELECT
        cl.*,
        100* SUM(cl.ltv) 
                OVER(
                    ORDER BY LTV DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            / SUM(cl.ltv) OVER()
            AS cumulative_revenue_pct,
        100.0* COUNT(*) 
                OVER(
                    ORDER BY cl.ltv DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            / COUNT(*) OVER()
            AS cumulative_customer_count_pct
    FROM
        customer_ltv cl
)
SELECT
    ROUND(cumulative_customer_count_pct , 2) AS customer_percentage,
    cumulative_revenue_pct AS revenue_percentage
FROM
    pareto_table
WHERE
    cumulative_revenue_pct >= 80
LIMIT 1