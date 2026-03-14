WITH
main
AS(
    SELECT DISTINCT
        s.orderkey,
        p.categoryname
    FROM
        sales s
    INNER JOIN product p
        ON s.productkey = p.productkey
),
category_pairs
AS(
    SELECT
        m1.orderkey,
        m1.categoryname AS category_A,
        m2.categoryname AS category_B
    FROM main m1
    JOIN main m2 ON m1.orderkey = m2.orderkey
    WHERE
        m1.categoryname < m2.categoryname
)
SELECT
    category_A,
    category_B,
    COUNT(*) AS number_of_orders_bought_together
FROM
    category_pairs cp
GROUP BY
    category_A,
    category_B
ORDER BY
    number_of_orders_bought_together DESC