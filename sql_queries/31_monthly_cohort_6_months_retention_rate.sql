WITH base_sales
AS(
    SELECT DISTINCT orderkey, customerkey, orderdate
    FROM sales
    WHERE
        orderdate >= CURRENT_DATE - INTERVAL '6 years'
),
monthly_cohort
AS(
    SELECT
        bs.customerkey,
        MIN(bs.orderdate) AS first_order_date,
        DATE_TRUNC('month', MIN(bs.orderdate))::DATE AS cohort_month
    FROM
        base_sales bs
    GROUP BY
        bs.customerkey
),
retained_flags
AS(
    SELECT
        mc.customerkey,
        mc.cohort_month,
        COUNT(DISTINCT bs.orderkey) AS num_orders_within_6_months,
        CASE
            WHEN COUNT(DISTINCT bs.orderkey) > 0 THEN 1 ELSE 0
        END AS retained_true_false
    FROM monthly_cohort mc
    LEFT JOIN base_sales bs
        ON mc.customerkey = bs.customerkey
        AND bs.orderdate > mc.first_order_date
        AND bs.orderdate <= mc.first_order_date + INTERVAL '6 months'
    GROUP BY
        mc.customerkey, mc.cohort_month, num_orders_within_6_months
)
SELECT
    cohort_month,
    SUM(retained_true_false) AS retained_customers,
    COUNT(retained_true_false) AS total_customers,
    100.0* SUM(retained_true_false) / COUNT(retained_true_false) AS retention_rate
FROM
    retained_flags
GROUP BY
    cohort_month
ORDER BY
    cohort_month