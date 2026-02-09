SELECT
    o_year,
    SUM(
        CASE
            WHEN nation = 'BRAZIL'
            THEN volume
            ELSE 0
        END
    ) * 1.0 / SUM(volume) AS mkt_share
FROM (
    SELECT
        YEAR(o.o_orderdate) AS o_year,
        l.l_extendedprice * (1 - l.l_discount) AS volume,
        n2.n_name AS nation
    FROM
        dbo.part     p,
        dbo.supplier s,
        dbo.lineitem l,
        dbo.orders   o,
        dbo.customer c,
        dbo.nation   n1,
        dbo.nation   n2,
        dbo.region   r
    WHERE
            p.p_partkey = l.l_partkey
        AND s.s_suppkey = l.l_suppkey
        AND l.l_orderkey = o.o_orderkey
        AND o.o_custkey = c.c_custkey
        AND c.c_nationkey = n1.n_nationkey
        AND n1.n_regionkey = r.r_regionkey
        AND r.r_name = 'AMERICA'
        AND s.s_nationkey = n2.n_nationkey
        AND o.o_orderdate BETWEEN '1995-01-01' AND '1996-12-31'
        AND p.p_type = 'ECONOMY ANODIZED STEEL'
) AS all_nations
GROUP BY
    o_year
ORDER BY
    o_year;
