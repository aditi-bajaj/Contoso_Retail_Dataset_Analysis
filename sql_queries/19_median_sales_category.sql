WITH facts
  AS (
      SELECT
        s.orderkey,
        EXTRACT (YEAR FROM s.orderdate) AS year,
        p.categoryname,
        s.quantity * s.netprice / s.exchangerate AS netrevenue
      FROM
        sales s
      JOIN product p
        ON s.productkey = p.productkey
      WHERE
        s.orderdate::DATE BETWEEN '2022-01-01' AND '2023-12-31'
      )

SELECT
  f.categoryname AS product_category,
  PERCENTILE_CONT(0.5) WITHIN GROUP
    (ORDER BY
        CASE
            WHEN f.year = 2022 THEN f.netrevenue END) AS median_revenue_2022,
  PERCENTILE_CONT(0.5) WITHIN GROUP
    (ORDER BY
        CASE
            WHEN f.year = 2023 THEN f.netrevenue END) AS median_revenue_2023
FROM
  facts f
GROUP BY
  product_category
ORDER BY
  product_category