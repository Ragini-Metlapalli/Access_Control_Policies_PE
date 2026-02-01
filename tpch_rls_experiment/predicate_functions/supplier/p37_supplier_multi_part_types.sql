-- P37: Supplier visible only if they supply parts from at least 3 different part types


CREATE FUNCTION dbo.p37_supplier_multi_part_types
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
        SELECT COUNT(DISTINCT p.p_type)
        FROM dbo.partsupp ps
        JOIN dbo.part p
          ON p.p_partkey = ps.ps_partkey
        WHERE ps.ps_suppkey = @suppkey
    ) >= 3;
GO
