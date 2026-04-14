WITH
facts
AS(
    SELECT
        customerkey,
        EXTRACT(YEAR FROM orderdate) AS purchase_year,
        cohort_year
    FROM
        cohort_analysis
),
num_customers
AS(
    SELECT
        cohort_year,
        purchase_year,
        COUNT(DISTINCT customerkey) AS customer_count,
        SUM(
            CASE WHEN cohort_year = purchase_year THEN COUNT(DISTINCT customerkey)
        END) OVER(PARTITION BY cohort_year) AS total_cohort_customers
    FROM
        facts f
    GROUP BY
        cohort_year,
        purchase_year
)
SELECT
    cohort_year,
    purchase_year - cohort_year AS years_since_cohort,
    ROUND(100.0* customer_count / total_cohort_customers , 2) AS customer_retention_pct
FROM
    num_customers