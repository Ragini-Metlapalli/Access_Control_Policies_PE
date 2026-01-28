USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p7_receipt_commit;
GO

CREATE FUNCTION dbo.p7_receipt_commit(
    @receipt DATE,
    @commit DATE
)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE USER_NAME() = 'user3'
   OR @receipt <= DATEADD(DAY, 30, @commit);
GO
