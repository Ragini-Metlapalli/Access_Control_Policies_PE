USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p2_no_carefully;
GO

CREATE FUNCTION dbo.p2_no_carefully(@comment VARCHAR(255))
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE USER_NAME() = 'user3'
   OR @comment IS NULL
   OR @comment NOT LIKE '%carefully%';
GO
