CREATE FUNCTION dbo.p_supplier_test
(
    @suppkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
FROM dbo.lineitem l
WHERE l.l_suppkey = @suppkey;
GO