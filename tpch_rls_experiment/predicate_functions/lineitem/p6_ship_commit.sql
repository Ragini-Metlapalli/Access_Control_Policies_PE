USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p6_ship_commit;
GO

CREATE FUNCTION dbo.p6_ship_commit(
    @ship DATE,
    @commit DATE
)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE USER_NAME() = 'user3'
   OR @ship <= DATEADD(DAY, 30, @commit);
GO
