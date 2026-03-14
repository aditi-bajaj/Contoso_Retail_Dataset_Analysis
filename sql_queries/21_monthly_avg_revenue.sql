WITH
  monthly_sales
  AS(
      SELECT
        TO_CHAR(orderdate, 'YYYY-MM') AS month,
        SUM(quantity * netprice / exchangerate) AS net_revenue
      FROM sales
      WHERE EXTRACT(YEAR FROM orderdate) = 2023
      GROUP BY month
      ORDER BY month
  )
SELECT
  month,
  net_revenue,
  AVG(net_revenue) OVER(
    ORDER BY month
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS three_month_rolling_avg,
  AVG(net_revenue) OVER(
    ORDER BY month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_avg_revenue
FROM monthly_sales ms