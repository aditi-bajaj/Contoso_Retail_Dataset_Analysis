WITH
yearly_cohort
  AS (
      SELECT
        customerkey,
        EXTRACT(YEAR FROM MIN (orderdate)) AS cohort_year
      FROM
        sales
      GROUP BY
        customerkey
      ),
facts
  AS (
        SELECT
          cohort_year,
          EXTRACT(YEAR FROM orderdate) AS purchase_year,
          SUM(quantity * netprice / exchangerate) AS net_revenue
        FROM
          sales s
        LEFT JOIN yearly_cohort y ON y.customerkey = s.customerkey
        GROUP BY
          cohort_year,
          purchase_year
      )

SELECT
  purchase_year AS business_year,
  SUM(net_revenue) OVER(PARTITION BY purchase_year) AS total_net_revenue,
  cohort_year,
  net_revenue AS cohort_net_revenue,
  CAST(net_revenue * 100 / SUM(net_revenue) OVER(PARTITION BY purchase_year) AS INTEGER) AS cohort_revenue_share_percentage
FROM
  facts
ORDER BY
  purchase_year,
  cohort_year