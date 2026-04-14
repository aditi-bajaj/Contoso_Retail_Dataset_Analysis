-- Customers who bought only from one product category ever and never from any other category

WITH customer_category
AS(
    SELECT
        s.customerkey,
        p.categorykey
    FROM
        sales s
    JOIN product p ON s.productkey = p.productkey
)
SELECT
    cc1.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    cc1.categorykey,
    p.categoryname AS product_category
FROM customer_category cc1
JOIN customer c ON c.customerkey = cc1.customerkey
JOIN product p ON p.categorykey = cc1.categorykey
WHERE NOT EXISTS(
    SELECT 1
    FROM customer_category cc2
    WHERE cc1.customerkey = cc2.customerkey
    AND cc1.categorykey <> cc2.categorykey
);

WITH customer_category
AS(
    SELECT
        s.customerkey,
        p.categorykey
    FROM
        sales s
    JOIN product p ON s.productkey = p.productkey
)
SELECT
    cc1.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    cc1.categorykey,
    p.categoryname AS product_category
FROM customer_category cc1
JOIN customer c ON c.customerkey = cc1.customerkey
JOIN product p ON p.categorykey = cc1.categorykey
LEFT JOIN customer_category cc2
    ON cc1.customerkey = cc2.customerkey
    AND cc1.categorykey <> cc2.categorykey
WHERE cc2.categorykey IS NULL;