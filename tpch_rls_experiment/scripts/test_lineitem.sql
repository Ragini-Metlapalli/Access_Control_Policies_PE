SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO


--Measure performance WITHOUT RLS

ALTER SECURITY POLICY dbo.lineitem_rls_policy WITH (STATE = OFF);
GO

EXECUTE AS USER = 'user1';

SELECT COUNT(*) FROM dbo.lineitem;

REVERT;
GO



--Measure performance WITH RLS

ALTER SECURITY POLICY dbo.lineitem_rls_policy WITH (STATE = ON);
GO

EXECUTE AS USER = 'user1';

SELECT COUNT(*) FROM dbo.lineitem;

REVERT;
GO
