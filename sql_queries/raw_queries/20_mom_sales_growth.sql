WITH
  monthly_revenue
  AS(
      SELECT
        TO_CHAR(orderdate, 'YYYY-MM') AS month,
        SUM(quantity * netprice / exchangerate) AS net_revenue
      FROM
        sales
      WHERE
        EXTRACT(YEAR FROM orderdate) = 2023
      GROUP BY
        month
      ORDER BY
        month
  )

SELECT *,
  100* (net_revenue - LAG(net_revenue) OVER(ORDER BY month)) /LAG(net_revenue) OVER(ORDER BY month) AS mom_growth_percentage
FROM
  monthly_revenue m