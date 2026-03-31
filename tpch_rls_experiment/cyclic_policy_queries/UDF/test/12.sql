DBCC FREEPROCCACHE;
DBCC DROPCLEANBUFFERS;
GO


-- Disable others
-- ALTER SECURITY POLICY query12_orders_policy_view WITH (STATE = OFF);
-- ALTER SECURITY POLICY query12_orders_policy_rls WITH (STATE = OFF);

SET STATISTICS TIME ON;
SET STATISTICS IO ON;


SELECT
    l.l_shipmode,
    SUM(CASE 
        WHEN o.o_orderpriority IN ('1-URGENT','2-HIGH') THEN 1 ELSE 0 END) AS high_line_count,
    SUM(CASE 
        WHEN o.o_orderpriority NOT IN ('1-URGENT','2-HIGH') THEN 1 ELSE 0 END) AS low_line_count
FROM dbo.orders o
JOIN dbo.lineitem l ON o.o_orderkey = l.l_orderkey
WHERE
    dbo.atomic_p11_udf(o.o_orderkey) = 1
    AND l.l_shipmode = 'SHIP'
    AND l.l_commitdate < l.l_receiptdate
    AND l.l_shipdate < l.l_commitdate
    AND l.l_receiptdate >= '1995-01-01'
    AND l.l_receiptdate < DATEADD(YEAR,1,'1995-01-01')
GROUP BY l.l_shipmode
ORDER BY l.l_shipmode
OPTION (
        RECOMPILE, 
        USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
GO