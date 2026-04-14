WITH product_sales
AS(
    SELECT
        p.categoryname AS product_category,
        s.productkey,
        p.productname AS product_name,
        SUM(s.quantity * s.netprice / s.exchangerate) AS total_sales
    FROM sales s
    JOIN product p ON s.productkey = p.productkey
    GROUP BY
        p.categoryname,
        s.productkey,
        p.productname
),
ranked_sales
AS(
    SELECT *,
        DENSE_RANK() OVER(
            PARTITION BY product_category
            ORDER BY total_sales DESC
        ) AS rank
    FROM product_sales ps
)
SELECT
    product_category,
    productkey,
    product_name,
    total_sales
FROM
    ranked_sales rs
WHERE
    rs.rank BETWEEN 1 AND 3