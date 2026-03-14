SELECT
  p.categoryname AS product_category,
  EXTRACT(YEAR FROM s.orderdate) AS order_year,
  SUM(s.quantity * s.netprice / s.exchangerate) AS net_revenue
FROM
  sales s
JOIN product p
  ON s.productkey = p.productkey
WHERE
  EXTRACT(YEAR FROM s.orderdate) >= 2020
GROUP BY
  product_category, order_year
ORDER BY
  order_year, product_category