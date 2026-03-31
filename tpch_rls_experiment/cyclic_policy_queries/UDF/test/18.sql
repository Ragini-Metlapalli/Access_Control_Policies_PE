DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO


-- Disable others
-- ALTER SECURITY POLICY query18_orders_customer_policy_view WITH (STATE = OFF);
-- ALTER SECURITY POLICY query18_orders_customer_policy_rls WITH (STATE = OFF);

SET STATISTICS TIME ON;
SET STATISTICS IO ON;


SELECT
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice,
    SUM(l.l_quantity)
FROM dbo.customer c
JOIN dbo.orders o ON c.c_custkey = o.o_custkey
JOIN dbo.lineitem l ON o.o_orderkey = l.l_orderkey
WHERE 
    dbo.atomic_p6_udf(c.c_custkey) = 1
    AND
    o.o_orderkey IN (
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
    o.o_totalprice DESC,
    o.o_orderdate
OPTION (
        RECOMPILE, 
        USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));

GO