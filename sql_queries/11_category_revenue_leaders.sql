/*
Category Revenue Leaders: Determines the customer who generated the highest total revenue in that category for each product category
*/

WITH
facts
    AS(
        SELECT
        p.categoryname AS product_category,
        s.customerkey AS customer_key,
        CONCAT_WS(' ', TRIM(c.givenname), TRIM(c.surname)) AS customer_name,
        SUM(s.quantity * s.netprice / s.exchangerate) AS total_revenue_generated,
        COUNT(*) AS number_of_orders
    FROM
        sales s
    JOIN product p ON p.productkey = s.productkey
    JOIN customer c ON c.customerkey = s.customerkey
    GROUP BY
        product_category,
        customer_key,
        customer_name
),

ranked
AS(
    SELECT
        *,
        DENSE_RANK() OVER(PARTITION BY product_category ORDER BY total_revenue_generated DESC) AS rank
    FROM
        facts
)

SELECT
    product_category,
    customer_key,
    customer_name,
    number_of_orders,
    total_revenue_generated
FROM
    ranked
WHERE
    rank = 1
ORDER BY
    product_category