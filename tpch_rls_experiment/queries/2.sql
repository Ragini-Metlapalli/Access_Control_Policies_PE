SELECT 
    s.s_acctbal,
    s.s_name,
    n.n_name,
    p.p_partkey,
    p.p_mfgr,
    s.s_address,
    s.s_phone,
    s.s_comment
FROM
    dbo.part p,
    dbo.supplier s,
    dbo.partsupp ps,
    dbo.nation n,
    dbo.region r
WHERE
    p.p_partkey = ps.ps_partkey
    AND s.s_suppkey = ps.ps_suppkey
    AND p.p_size = 38
    AND p.p_type LIKE '%TIN'
    AND s.s_nationkey = n.n_nationkey
    AND n.n_regionkey = r.r_regionkey
    AND r.r_name = 'MIDDLE EAST'
    AND ps.ps_supplycost = (
        SELECT MIN(ps2.ps_supplycost)
        FROM
            dbo.partsupp ps2,
            dbo.supplier s2,
            dbo.nation n2,
            dbo.region r2
        WHERE
            ps2.ps_partkey = p.p_partkey
            AND s2.s_suppkey = ps2.ps_suppkey
            AND s2.s_nationkey = n2.n_nationkey
            AND n2.n_regionkey = r2.r_regionkey
            AND r2.r_name = 'MIDDLE EAST'
    )
ORDER BY
    s.s_acctbal DESC,
    n.n_name,
    s.s_name,
    p.p_partkey;
