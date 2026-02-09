WITH big_orders AS (
    SELECT l_orderkey
    FROM dbo.lineitem
    GROUP BY l_orderkey
    HAVING SUM(l_quantity) > 300
)
SELECT
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice,
    SUM(l.l_quantity) AS sum_qty
FROM dbo.customer c
JOIN dbo.orders o
    ON c.c_custkey = o.o_custkey
JOIN dbo.lineitem l
    ON o.o_orderkey = l.l_orderkey
JOIN big_orders bo
    ON bo.l_orderkey = o.o_orderkey
GROUP BY
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice
ORDER BY
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_totalprice DESC,
    o.o_orderdate;
