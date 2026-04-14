-- Customers who bought only one product ever and never bought any other product

WITH one_pdt_customers
AS(
SELECT
    s1.customerkey,
    MIN(s1.productkey) AS productkey
FROM sales s1
WHERE NOT EXISTS
(
    SELECT 1
    FROM sales s2
    WHERE s2.customerkey = s1.customerkey AND s2.productkey <> s1.productkey
)
GROUP BY
    s1.customerkey
)
SELECT
    opc.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country,
    opc.productkey,
    p.productname AS product_name,
    p.categoryname AS product_category
FROM one_pdt_customers opc
JOIN customer c ON c.customerkey = opc.customerkey
JOIN product p ON p.productkey = opc.productkey
ORDER BY opc.customerkey;


WITH one_pdt_customers
AS(
    SELECT
        customerkey,
        MIN(productkey) AS productkey
    FROM sales
    GROUP BY customerkey
    HAVING COUNT(DISTINCT productkey) = 1
)
SELECT
    opc.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country,
    opc.productkey,
    p.productname AS product_name,
    p.categoryname AS product_category
FROM one_pdt_customers opc
JOIN customer c ON c.customerkey = opc.customerkey
JOIN product p ON p.productkey = opc.productkey
ORDER BY opc.customerkey