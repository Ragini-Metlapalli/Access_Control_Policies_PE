SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO


--Measure performance WITHOUT RLS

-- ALTER SECURITY POLICY dbo.lineitem_rls_policy WITH (STATE = OFF);
-- GO

-- EXECUTE AS USER = 'user1';

-- SELECT COUNT(*) FROM dbo.lineitem;

-- REVERT;
-- GO



--Measure performance WITH RLS

ALTER SECURITY POLICY dbo.q21_p19_p40 WITH (STATE = ON);
GO
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
-- EXECUTE AS USER = 'user1';

-- SELECT COUNT(*) FROM dbo.lineitem;
SELECT
    s.s_name,
    COUNT(*) AS numwait
FROM
    dbo.supplier s,
    dbo.lineitem l1,
    dbo.orders o,
    dbo.nation n
WHERE
    s.s_suppkey = l1.l_suppkey
    AND o.o_orderkey = l1.l_orderkey
    AND o.o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND EXISTS (
        SELECT *
        FROM dbo.lineitem l2
        WHERE
            l2.l_orderkey = l1.l_orderkey
            AND l2.l_suppkey <> l1.l_suppkey
    )
    AND NOT EXISTS (
        SELECT *
        FROM dbo.lineitem l3
        WHERE
            l3.l_orderkey = l1.l_orderkey
            AND l3.l_suppkey <> l1.l_suppkey
            AND l3.l_receiptdate > l3.l_commitdate
    )
    AND s.s_nationkey = n.n_nationkey 
    AND n.n_name = 'INDIA' --originally GERMANY was there
GROUP BY
    s.s_name
ORDER BY
    numwait DESC,
    s.s_name
-- OPTION (MAXDOP 1); --max parallelism is 1

REVERT;
GO
