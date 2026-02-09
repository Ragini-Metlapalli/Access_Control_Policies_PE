SELECT
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice,
    SUM(l.l_quantity) AS sum_qty
FROM
    dbo.customer c,
    dbo.orders o,
    dbo.lineitem l
WHERE
    c.c_custkey = o.o_custkey
    AND o.o_orderkey = l.l_orderkey
    AND o.o_orderkey IN (
        SELECT l2.l_orderkey
        FROM dbo.lineitem l2
        GROUP BY l2.l_orderkey
        HAVING SUM(l2.l_quantity) > 300
    )
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
