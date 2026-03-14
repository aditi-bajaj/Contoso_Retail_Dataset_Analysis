WITH
customer_ltv
    AS(
        SELECT
            customerkey,
            SUM(total_net_revenue) AS ltv,
            countryfull AS country
        FROM
            cohort_analysis ca
        GROUP BY
            customerkey,
            country
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
                WHEN cl.ltv <= p25th THEN 'Low Value'
                WHEN cl.ltv >= p75th THEN 'High Value'
                ELSE 'Mid Value'
            END AS customer_segment
        FROM
            customer_ltv cl
        CROSS JOIN percentiles p
    )

SELECT
    country,
    100* COUNT(DISTINCT
        CASE WHEN customer_segment = 'High Value' THEN customerkey
        END) / COUNT(DISTINCT customerkey) AS high_value_customers_pct,
    100* COUNT(DISTINCT
        CASE WHEN customer_segment = 'Mid Value' THEN customerkey
        END) / COUNT(DISTINCT customerkey) AS mid_value_customers_pct,
    100* COUNT(DISTINCT
        CASE WHEN customer_segment = 'Low Value' THEN customerkey
        END) / COUNT(DISTINCT customerkey) AS low_value_customers_pct,
    COUNT(DISTINCT customerkey) AS total_customers
FROM
    segments s
GROUP BY
    country
ORDER BY
    high_value_customers_pct DESC,
    mid_value_customers_pct DESC