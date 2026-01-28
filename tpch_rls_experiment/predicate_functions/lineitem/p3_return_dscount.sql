USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p3_return_discount;
GO

CREATE FUNCTION dbo.p3_return_discount(
    @ret CHAR(1),
    @disc DECIMAL(4,2)
)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE USER_NAME() = 'user3'
   OR (@ret <> 'R' OR @disc < 0.05);
GO
