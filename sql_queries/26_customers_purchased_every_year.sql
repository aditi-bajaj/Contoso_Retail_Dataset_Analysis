WITH years
AS(
    SELECT
        COUNT(DISTINCT EXTRACT(YEAR FROM orderdate)) AS num_total_years
    FROM
        sales s
),
customer_years
AS(
    SELECT
        s.customerkey,
        COUNT(DISTINCT EXTRACT(YEAR FROM s.orderdate)) AS num_purchase_years
    FROM
        sales s
    GROUP BY
        s.customerkey
)
SELECT
    cy.customerkey,
    CONCAT_WS(' ', c.givenname, c.surname) AS customer_name,
    c.country
FROM
    customer_years cy
INNER JOIN customer c ON cy.customerkey = c.customerkey
CROSS JOIN years y
WHERE
    cy.num_purchase_years = y.num_total_years