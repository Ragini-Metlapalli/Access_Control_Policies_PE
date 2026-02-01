-- P43: Supplier visible only if their supplied parts cover at least 2 different part sizes

CREATE FUNCTION dbo.p43_supplier_multi_part_sizes
(
    @suppkey BIGINT
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
        SELECT COUNT(DISTINCT p.p_size)
        FROM dbo.partsupp ps
        JOIN dbo.part p
          ON p.p_partkey = ps.ps_partkey
        WHERE ps.ps_suppkey = @suppkey
    ) >= 2;
GO
