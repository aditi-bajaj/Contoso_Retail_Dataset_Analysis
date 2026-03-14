WITH
main
AS(
    SELECT DISTINCT
        s.orderkey,
        p.productkey,
        p.productname
    FROM
        sales s
    INNER JOIN product p
        ON s.productkey = p.productkey
),
product_pairs
AS(
    SELECT
        m1.orderkey,
        m1.productkey AS product_A_key,
        m1.productname AS product_A,
        m2.productkey AS product_B_key,
        m2.productname AS product_B
    FROM main m1
    JOIN main m2 ON m1.orderkey = m2.orderkey
    WHERE
        m1.productkey < m2.productkey
),
ranked_partners
AS(
    SELECT
        product_A_key,
        product_A,
        product_B_key,
        product_B,
        COUNT(*) AS number_of_orders_together,
        DENSE_RANK() OVER(
            PARTITION BY product_A_key
            ORDER BY COUNT(*) DESC) AS rank
    FROM
        product_pairs pp
    GROUP BY
        product_A_key,
        product_B_key,
        product_A,
        product_B
)
SELECT
    product_A_key AS product_key,
    product_A AS product,
    product_B_key AS most_common_partner_product_key,
    product_B AS most_common_partner_product,
    number_of_orders_together
FROM
    ranked_partners
WHERE
    rank = 1