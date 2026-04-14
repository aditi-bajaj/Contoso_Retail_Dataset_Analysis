CREATE OR REPLACE VIEW public.cohort_analysis
AS WITH facts AS (
         SELECT s.customerkey,
            s.orderdate,
            sum(s.quantity::double precision * s.netprice / s.exchangerate) AS total_net_revenue,
            count(s.orderkey) AS num_orders
           FROM sales s
          GROUP BY s.orderdate, s.customerkey
        )
 SELECT f.customerkey,
    f.orderdate,
    f.total_net_revenue,
    f.num_orders,
    min(f.orderdate) OVER (PARTITION BY f.customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(f.orderdate) OVER (PARTITION BY f.customerkey)) AS cohort_year,
    concat_ws(' '::text, TRIM(BOTH FROM c.givenname), TRIM(BOTH FROM c.surname)) AS customer_name,
    c.age,
    c.countryfull
   FROM customer c
     JOIN facts f ON f.customerkey = c.customerkey
  ORDER BY f.customerkey, f.orderdate;