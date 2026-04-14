-- Customers who never bought from more than one store

WITH one_str_customers
AS(
    SELECT
        s1.customerkey,
        MIN(s1.storekey) AS storekey
    FROM sales s1
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM sales s2
        WHERE s1.customerkey = s2.customerkey
        AND s1.storekey <> s2.storekey
    )
    GROUP BY customerkey
)
SELECT
    osc.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country AS customer_country,
    osc.storekey,
    st.countryname AS store_country,
    st.description AS store_description
FROM one_str_customers osc
JOIN customer c ON c.customerkey = osc.customerkey
JOIN store st ON st.storekey = osc.storekey
ORDER BY osc.customerkey;


WITH one_str_customers
AS(
    SELECT
        customerkey,
        MIN(storekey) AS storekey
    FROM sales
    GROUP BY customerkey
    HAVING COUNT(DISTINCT storekey) = 1
)
SELECT
    osc.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country AS customer_country,
    osc.storekey,
    st.countryname AS store_country,
    st.description AS store_description
FROM one_str_customers osc
JOIN customer c ON c.customerkey = osc.customerkey
JOIN store st ON st.storekey = osc.storekey
ORDER BY osc.customerkey