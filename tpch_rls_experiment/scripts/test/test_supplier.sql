SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO


-- CREATE NONCLUSTERED INDEX idx_partsupp_part_supp
-- ON dbo.partsupp (ps_partkey, ps_suppkey);
-- GO

-- CREATE NONCLUSTERED INDEX idx_partsupp_supp_part
-- ON dbo.partsupp (ps_suppkey, ps_partkey);
-- GO


--Measure performance WITHOUT RLS

ALTER SECURITY POLICY dbo.supplier_rls_policy WITH (STATE = OFF);
GO

EXECUTE AS USER = 'user1';

SELECT COUNT(*) FROM dbo.supplier;

REVERT;
GO



--Measure performance WITH RLS

ALTER SECURITY POLICY dbo.supplier_rls_policy WITH (STATE = ON);
GO

EXECUTE AS USER = 'user1';

SELECT COUNT(*) FROM dbo.supplier;

REVERT;
GO


-- DROP INDEX idx_partsupp_part_supp ON dbo.partsupp;
-- GO

-- DROP INDEX idx_partsupp_supp_part ON dbo.partsupp;
-- GO

SELECT
    i.name,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups
FROM sys.dm_db_index_usage_stats ius
JOIN sys.indexes i
    ON i.index_id = ius.index_id
   AND i.object_id = ius.object_id
WHERE i.object_id = OBJECT_ID('dbo.partsupp');


SELECT
    t.name AS TableName,
    ind.name AS IndexName,
    ind.type_desc AS IndexType
FROM
    sys.indexes AS ind
INNER JOIN
    sys.tables AS t ON ind.object_id = t.object_id
WHERE
    t.name = 'dbo.partsupp'
    AND ind.name IS NOT NULL
ORDER BY
    t.name, ind.type_desc;
