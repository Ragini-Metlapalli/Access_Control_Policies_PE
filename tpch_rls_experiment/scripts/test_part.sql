SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO


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
