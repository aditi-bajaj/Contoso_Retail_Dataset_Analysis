-- Cohort Revenue by first purchase year
-- Adjusted for time in market
WITH facts
	AS(
		SELECT
			s.customerkey,
			s.orderdate,
			SUM(s.quantity * s.netprice / s.exchangerate) AS total_net_revenue,
			COUNT(s.orderkey) AS num_orders
		FROM
			sales s
		GROUP BY
			s.orderdate,
			s.customerkey
	),
cohort_analysis
  AS(
    SELECT
      f.*,
      MIN(f.orderdate) OVER(PARTITION BY f.customerkey) AS first_purchase_date,
      EXTRACT(YEAR FROM MIN(f.orderdate) OVER(PARTITION BY f.customerkey)) AS cohort_year
    FROM facts f
  )
SELECT
	cohort_year,
	SUM(total_net_revenue) AS total_revenue,
	COUNT(DISTINCT customerkey) AS total_customers,
	SUM(total_net_revenue) / COUNT(DISTINCT customerkey) AS customer_revenue
FROM
	cohort_analysis ca
WHERE
	orderdate = first_purchase_date
GROUP BY
	cohort_year