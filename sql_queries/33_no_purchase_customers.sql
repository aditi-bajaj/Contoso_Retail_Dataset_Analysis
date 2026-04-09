SELECT
    c.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country
FROM
    customer c
LEFT JOIN sales s
    ON c.customerkey = s.customerkey
WHERE
    s.customerkey IS NULL
ORDER BY
    c.customerkey;

SELECT
    c.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country
FROM
    customer c
WHERE NOT EXISTS(
    SELECT 1
    FROM
        sales s
    WHERE s.customerkey = c.customerkey
)
ORDER BY
    c.customerkey;