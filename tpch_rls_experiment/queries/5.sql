SELECT
    n.n_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM
    dbo.customer c
JOIN dbo.orders o
    ON c.c_custkey = o.o_custkey
JOIN dbo.lineitem l
    ON l.l_orderkey = o.o_orderkey
JOIN dbo.supplier s
    ON l.l_suppkey = s.s_suppkey
JOIN dbo.nation n
    ON s.s_nationkey = n.n_nationkey
JOIN dbo.region r
    ON n.n_regionkey = r.r_regionkey
WHERE
    c.c_nationkey = s.s_nationkey
    AND r.r_name = 'MIDDLE EAST'
    AND o.o_orderdate >= '1994-01-01'
    AND o.o_orderdate < DATEADD(YEAR, 1, '1994-01-01')
GROUP BY
    n.n_name
ORDER BY
    revenue DESC;
