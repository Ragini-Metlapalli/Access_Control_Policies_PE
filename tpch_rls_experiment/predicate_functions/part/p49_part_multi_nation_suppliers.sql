-- P49: Part visible only if it is supplied by suppliers from more than one nation

CREATE FUNCTION dbo.p49_part_multi_nation_suppliers
(
    @partkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR
    (
        SELECT COUNT(DISTINCT s.s_nationkey)
        FROM dbo.partsupp ps
        JOIN dbo.supplier s
          ON s.s_suppkey = ps.ps_suppkey
        WHERE ps.ps_partkey = @partkey
    ) > 1;
GO
