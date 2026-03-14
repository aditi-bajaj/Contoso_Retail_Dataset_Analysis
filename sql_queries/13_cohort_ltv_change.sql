WITH
  cohort_year_customer_ltv
  AS(
      SELECT
        customerkey,
        EXTRACT(YEAR FROM MIN(orderdate)) AS cohort_year,
        SUM(quantity * netprice / exchangerate) AS customer_ltv
      FROM
        sales
      GROUP BY
        customerkey
  ),
  cohort_ltv
  AS(
      SELECT
        cohort_year,
        AVG(customer_ltv) AS avg_cohort_ltv
      FROM
        cohort_year_customer_ltv cc
      GROUP BY
        cohort_year
  )
SELECT
  cohort_year,
  avg_cohort_ltv,
  100* (avg_cohort_ltv - LAG(avg_cohort_ltv) OVER(ORDER BY cohort_year))
        / LAG(avg_cohort_ltv) OVER(ORDER BY cohort_year) AS ltv_change_percentage
FROM
  cohort_ltv cl
ORDER BY
  cohort_year