SELECT
    ps.ps_partkey,
    SUM(ps.ps_supplycost * ps.ps_availqty) AS value
FROM
    dbo.partsupp ps,
    dbo.supplier s,
    dbo.nation n
WHERE
        ps.ps_suppkey = s.s_suppkey
    AND s.s_nationkey = n.n_nationkey
    AND n.n_name = 'GERMANY'
GROUP BY
    ps.ps_partkey
HAVING
    SUM(ps.ps_supplycost * ps.ps_availqty) >
    (
        SELECT
            SUM(ps2.ps_supplycost * ps2.ps_availqty) * 0.0001
        FROM
            dbo.partsupp ps2,
            dbo.supplier s2,
            dbo.nation n2
        WHERE
                ps2.ps_suppkey = s2.s_suppkey
            AND s2.s_nationkey = n2.n_nationkey
            AND n2.n_name = 'GERMANY'
    )
ORDER BY
    value DESC;
