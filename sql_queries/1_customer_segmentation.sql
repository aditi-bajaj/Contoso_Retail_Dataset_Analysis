WITH
customer_ltv
    AS(
        SELECT
            customerkey,
            customer_name,
            SUM(total_net_revenue) AS ltv
        FROM
            cohort_analysis ca
        GROUP BY
            customerkey,
            customer_name
    ),
percentiles
    AS(
        SELECT
            PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ltv) AS p25th,
            PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ltv) AS p75th
        FROM customer_ltv cl
    ),
segments
    AS(
        SELECT
        cl.*,
        CASE 
            WHEN cl.ltv < p.p25th THEN 'Low Value'
            WHEN cl.ltv <= p.p75th THEN 'Mid Value'
            ELSE 'High Value'
        END AS customer_segment
    FROM
        customer_ltv cl
    CROSS JOIN percentiles p
    )
SELECT
    customer_segment,
    ROUND( (100* SUM(s.ltv) 
                / SUM(SUM(s.ltv)) OVER()) ::NUMERIC ,1) AS ltv_share_pct,
    AVG(s.ltv) AS avg_ltv
FROM
    segments s
GROUP BY
    customer_segment
ORDER BY
    ltv_share_pct DESC