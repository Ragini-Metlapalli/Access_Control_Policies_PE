-- Query 1: without UDF (baseline, no policy applied)
SELECT TOP 10
    l.l_orderkey,
    l.l_suppkey,
    l.l_extendedprice
FROM dbo.lineitem l
JOIN dbo.supplier s
    ON l.l_suppkey = s.s_suppkey;
GO

-- Query 2: with UDF black box applied (policy enforced)
SELECT TOP 10
    l.l_orderkey,
    l.l_suppkey,
    l.l_extendedprice
FROM dbo.lineitem l
JOIN dbo.supplier s
    ON l.l_suppkey = s.s_suppkey
WHERE dbo.udf_dummy_blackbox(l.l_suppkey) = 1
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
GO


SELECT COUNT(*)
FROM dbo.lineitem l


SELECT COUNT(*)
FROM dbo.lineitem l
WHERE dbo.udf_dummy_blackbox(l.l_suppkey) = 1;


SELECT COUNT(*)
FROM dbo.lineitem l
WHERE dbo.udf_dummy_blackbox(l.l_suppkey) = 1
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));


