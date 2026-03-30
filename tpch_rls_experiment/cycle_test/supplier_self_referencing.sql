DROP FUNCTION IF EXISTS dbo.p_supplier_recursive
GO

CREATE FUNCTION dbo.p_supplier_recursive
(
    @suppkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN

SELECT 1 AS allowed
FROM dbo.supplier s2
WHERE s2.s_suppkey = @suppkey;
GO