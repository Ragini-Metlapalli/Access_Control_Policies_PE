USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p4_open_not_returned;
GO

CREATE FUNCTION dbo.p4_open_not_returned(
    @status CHAR(1),
    @ret CHAR(1)
)
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE USER_NAME() = 'user3'
   OR (@status = 'O' AND @ret <> 'R');
GO