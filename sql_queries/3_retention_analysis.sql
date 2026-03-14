WITH
customer_activity
AS(
    SELECT
        customerkey,
        MAX(orderdate) AS last_purchase_date,
        cohort_year,
        CASE 
            WHEN MAX(orderdate) >= (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
                THEN 'Active' ELSE 'Churned'
        END AS customer_status
    FROM
        cohort_analysis
    WHERE
        first_purchase_date <= (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
    GROUP BY
        customerkey,
        cohort_year
)
SELECT
    'Cohort-wise' AS metric_level,
    cohort_year,
    customer_status,
    COUNT(customerkey) AS num_customers,
    SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
    ROUND(100 * COUNT(customerkey) 
        / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) , 2) AS status_percentage
FROM
    customer_activity
GROUP BY
    cohort_year,
    customer_status

UNION ALL

SELECT
    'Overall' AS metric_level,
    NULL AS cohort_year,
    customer_status,
    COUNT(customerkey) AS num_customers,
    SUM(COUNT(customerkey)) OVER() AS total_customers,
    ROUND(100 * COUNT(customerkey) / SUM(COUNT(customerkey)) OVER() , 2) AS status_percentage
FROM
    customer_activity
GROUP BY
    customer_status

ORDER BY
    cohort_year,
    customer_status