SELECT
    c.c_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    c.c_acctbal,
    n.n_name,
    c.c_address,
    c.c_phone,
    c.c_comment
FROM dbo.customer AS c
JOIN dbo.orders   AS o ON c.c_custkey = o.o_custkey
JOIN dbo.lineitem AS l ON l.l_orderkey = o.o_orderkey
JOIN dbo.nation   AS n ON c.c_nationkey = n.n_nationkey
WHERE o.o_orderdate >= '1994-01-01'
  AND o.o_orderdate <= '1994-03-31'
  AND l.l_returnflag = 'R'
GROUP BY
    n.n_name,
    c.c_name,
    c.c_address,
    c.c_phone,
    c.c_acctbal,
    c.c_comment
ORDER BY
    revenue DESC,
    c.c_name ASC,
    c.c_acctbal ASC,
    c.c_phone ASC,
    n.n_name ASC,
    c.c_address ASC,
    c.c_comment ASC;
