WITH
  cohort
  AS(
      SELECT
        customerkey,
        EXTRACT(YEAR FROM MIN (orderdate)) AS cohort_year
      FROM
        sales
      GROUP BY
        customerkey
      ),
  facts
  AS(
      SELECT
        EXTRACT(YEAR FROM s.orderdate) AS business_year,
        c.cohort_year,
        COUNT(DISTINCT s.customerkey) AS num_customers
      FROM
        sales s
      JOIN cohort c ON c.customerkey = s.customerkey
      GROUP BY
        business_year,
        cohort_year
      )
SELECT
  business_year,
  SUM(num_customers) OVER(PARTITION BY business_year) AS customer_count,
  cohort_year,
  num_customers AS cohort_customer_count,
  CAST(num_customers * 100 / SUM(num_customers) OVER(PARTITION BY business_year) AS INTEGER) AS cohort_customer_share_percentage
FROM
  facts f
ORDER BY
  business_year,
  cohort_year