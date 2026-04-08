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

ALTER SECURITY POLICY dbo.lineitem_rls_policy WITH (STATE = ON);
GO
-- CHECKPOINT;
-- DBCC DROPCLEANBUFFERS;
EXECUTE AS USER = 'user1';

-- SELECT COUNT(*) FROM dbo.lineitem;
SELECT
    l.l_shipmode,
    SUM(
        CASE
            WHEN o.o_orderpriority IN ('1-URGENT', '2-HIGH')
            THEN 1
            ELSE 0
        END
    ) AS high_line_count,
    SUM(
        CASE
            WHEN o.o_orderpriority NOT IN ('1-URGENT', '2-HIGH')
            THEN 1
            ELSE 0
        END
    ) AS low_line_count
FROM
    dbo.orders o,
    dbo.lineitem l
WHERE
        o.o_orderkey = l.l_orderkey
    AND l.l_shipmode IN ('MAIL', 'SHIP')
    AND l.l_commitdate < l.l_receiptdate
    AND l.l_shipdate < l.l_commitdate
    AND l.l_receiptdate >= '1994-01-01'
    AND l.l_receiptdate <  DATEADD(YEAR, 1, '1994-01-01')
GROUP BY
    l.l_shipmode
ORDER BY
    l.l_shipmode;

REVERT;
GO
