/*
Compare 2022 vs 2023 for:
- Total net revenue of orders < Median Order Revenue (Low Revenue)
- Total net revenue of orders > Median Order Revenue (High Revenue)
*/

WITH facts
  AS (
      SELECT
        EXTRACT (YEAR FROM s.orderdate) AS year,
        p.categoryname,
        s.quantity * s.netprice / s.exchangerate AS netrevenue
      FROM
        sales s
      JOIN product p
        ON s.productkey = p.productkey
      WHERE
        s.orderdate::DATE BETWEEN '2022-01-01' AND '2023-12-31'
      ),
  median_value
    AS (
        SELECT
          categoryname,
          PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY netrevenue) AS median
        FROM
          facts f
        GROUP BY
          categoryname
      )

SELECT
  f.categoryname AS product_category,
  SUM(  CASE
          WHEN f.year = 2022 AND f.netrevenue < mv.median
          THEN f.netrevenue
        END) AS low_revenue_2022,
  SUM(  CASE
          WHEN f.year = 2022 AND f.netrevenue > mv.median
          THEN f.netrevenue
        END) AS high_revenue_2022,
  SUM(  CASE
          WHEN f.year = 2023 AND f.netrevenue < mv.median
          THEN f.netrevenue
        END) AS low_revenue_2023,
  SUM(  CASE
          WHEN f.year = 2023 AND f.netrevenue > mv.median
          THEN f.netrevenue
        END) AS high_revenue_2023
FROM
  facts f
JOIN median_value mv
  ON mv.categoryname = f.categoryname
GROUP BY
  product_category
ORDER BY
  product_category