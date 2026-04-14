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
percentiles
AS(
    SELECT
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY ltv) AS p90th,
        PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY ltv) AS p80th,
        PERCENTILE_CONT(0.7) WITHIN GROUP (ORDER BY ltv) AS p70th
    FROM customer_ltv cl
),
segments
AS(
    SELECT
    cl.*,
    CASE WHEN cl.ltv >= p.p90th THEN 'Yes' END AS top_10,
    CASE WHEN cl.ltv >= p.p80th THEN 'Yes' END AS top_20,
    CASE WHEN cl.ltv >= p.p70th THEN 'Yes' END AS top_30
FROM
    customer_ltv cl, percentiles p
),
revenue
AS(
    SELECT
    SUM(
        CASE WHEN top_10 = 'Yes' THEN ltv
        END) AS top_10_revenue,
    SUM(
        CASE WHEN top_20 = 'Yes' THEN ltv
        END) AS top_20_revenue,
    SUM(
        CASE WHEN top_30 = 'Yes' THEN ltv
        END) AS top_30_revenue,
    SUM(s.ltv) AS total_revenue
    FROM
        segments s
)

SELECT
    ROUND((100* top_10_revenue / total_revenue)::NUMERIC, 2) AS top_10_pct_customers_revenue_share,
    ROUND((100* top_20_revenue / total_revenue)::NUMERIC, 2) AS top_20_pct_customers_revenue_share,
    ROUND((100* top_30_revenue / total_revenue)::NUMERIC, 2) AS top_30_pct_customers_revenue_share
FROM
    revenue