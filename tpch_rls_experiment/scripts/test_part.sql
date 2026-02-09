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

ALTER SECURITY POLICY dbo.part_rls_policy WITH (STATE = OFF);
GO

EXECUTE AS USER = 'user1';

SELECT COUNT(*) FROM dbo.part;

REVERT;
GO



--Measure performance WITH RLS

ALTER SECURITY POLICY dbo.part_rls_policy WITH (STATE = ON);
GO

EXECUTE AS USER = 'user1';

SELECT COUNT(*) FROM dbo.part;

REVERT;
GO


-- DROP INDEX idx_partsupp_part_supp ON dbo.partsupp;
-- GO

-- DROP INDEX idx_partsupp_supp_part ON dbo.partsupp;
-- GO
