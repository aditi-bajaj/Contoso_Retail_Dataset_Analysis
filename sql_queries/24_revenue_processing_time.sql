SELECT
  EXTRACT(YEAR FROM orderdate) AS year,
  CAST(SUM(quantity * netprice / exchangerate) AS INTEGER) AS net_revenue,
  ROUND(AVG(deliverydate::DATE - orderdate::DATE), 2) AS avg_processing_time

FROM
  sales
WHERE
  orderdate >= (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Kolkata')::DATE - INTERVAL '6 years'
GROUP BY
  year
ORDER BY
  year