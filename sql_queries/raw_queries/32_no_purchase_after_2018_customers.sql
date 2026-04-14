-- No purchases after 2018
SELECT
    s1.customerkey,
    MAX(s1.orderdate) AS last_purchase_date
FROM
    sales s1
WHERE NOT EXISTS
(
    SELECT 1
    FROM
        sales s2
    WHERE
        s1.customerkey = s2.customerkey
        AND s2.orderdate > '2018-12-31'
)
GROUP BY
    s1.customerkey
ORDER BY
    s1.customerkey;

-- No purchases after 2018, but at least one purchase in 2018
SELECT
    s1.customerkey,
    MAX(s1.orderdate) AS last_purchase_date,
    COUNT(*) AS num_orders_2018
FROM
    sales s1
WHERE NOT EXISTS
(
    SELECT 1
    FROM
        sales s2
    WHERE
        s1.customerkey = s2.customerkey
        AND s2.orderdate > '2018-12-31'
)
AND s1.orderdate BETWEEN '2018-01-01' AND '2018-12-31'
GROUP BY
    s1.customerkey
ORDER BY
    last_purchase_date;

-- No purchases after 2018, but at least one purchase in 2018
SELECT
    s1.customerkey,
    MAX(s1.orderdate) AS last_purchase_date,
    COUNT(*) AS num_orders_2018
FROM
    sales s1
WHERE NOT EXISTS
(
    SELECT 1
    FROM
        sales s2
    WHERE
        s1.customerkey = s2.customerkey
        AND s2.orderdate > '2018-12-31'
)
GROUP BY
    s1.customerkey
HAVING MAX(s1.orderdate) BETWEEN '2018-01-01' AND '2018-12-31'
ORDER BY
    last_purchase_date