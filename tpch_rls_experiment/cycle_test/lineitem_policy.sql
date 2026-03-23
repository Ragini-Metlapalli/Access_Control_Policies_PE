CREATE FUNCTION dbo.p_lineitem_test
(
    @suppkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
FROM dbo.supplier s
WHERE s.s_suppkey = @suppkey;
GO