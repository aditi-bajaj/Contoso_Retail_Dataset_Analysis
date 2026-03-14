WITH facts
  AS (
      SELECT
        p.categoryname,
        s.quantity * s.netprice / s.exchangerate AS netrevenue
      FROM
        sales s
      JOIN product p
        ON s.productkey = p.productkey
      WHERE
        s.orderdate::DATE BETWEEN '2022-01-01' AND '2023-12-31'
      ),
  percentile
    AS (
        SELECT
          categoryname,
          PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY netrevenue) AS p25th,
          PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY netrevenue) AS p75th
        FROM
          facts f
        GROUP BY
          categoryname
      )

SELECT
  f.categoryname AS product_category,
  CASE
    WHEN f.netrevenue <= pt.p25th THEN '3- Low'
    WHEN f.netrevenue >= pt.p75th THEN '1- High'
    ELSE '2- Medium'
  END AS revenue_tier,
  SUM(f.netrevenue) AS total_revenue
FROM
  facts f
JOIN percentile pt
  ON pt.categoryname = f.categoryname
GROUP BY
  product_category, revenue_tier
ORDER BY
  product_category, revenue_tier