ALTER SECURITY POLICY dbo.test_cycle WITH (STATE = ON);
GO
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
EXECUTE AS USER = 'user1';

SELECT l.l_orderkey, s.s_name
FROM dbo.lineitem l
JOIN dbo.supplier s 
    ON l.l_suppkey = s.s_suppkey
WHERE l.l_receiptdate > l.l_commitdate;

REVERT
GO


ALTER SECURITY POLICY dbo.test_cycle WITH (STATE = OFF);
GO
CHECKPOINT;
DBCC DROPCLEANBUFFERS;
EXECUTE AS USER = 'user1';

SELECT l.l_orderkey, s.s_name
FROM dbo.lineitem l
JOIN dbo.supplier s 
    ON l.l_suppkey = s.s_suppkey
WHERE l.l_receiptdate > l.l_commitdate;

REVERT
GO