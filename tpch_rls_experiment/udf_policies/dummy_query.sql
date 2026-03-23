-- Query 1: without UDF (baseline, no policy applied)
SELECT TOP 10
    l.l_orderkey,
    l.l_suppkey,
    l.l_extendedprice
FROM dbo.lineitem l
JOIN dbo.supplier s
    ON l.l_suppkey = s.s_suppkey;


-- Query 2: with UDF black box applied (policy enforced)
SELECT TOP 10
    l.l_orderkey,
    l.l_suppkey,
    l.l_extendedprice
FROM dbo.lineitem l
JOIN dbo.supplier s
    ON l.l_suppkey = s.s_suppkey
WHERE dbo.udf_dummy_blackbox(l.l_suppkey) = 1;