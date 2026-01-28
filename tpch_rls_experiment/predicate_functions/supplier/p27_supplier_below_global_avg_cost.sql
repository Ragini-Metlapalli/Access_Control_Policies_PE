-- P27: Supplier visible only if their average supply cost is below the global average supply cost


CREATE FUNCTION dbo.p27_supplier_below_global_avg_cost
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
        -- Supplier's average supply cost
        (
            SELECT AVG(ps.ps_supplycost)
            FROM dbo.partsupp ps
            WHERE ps.ps_suppkey = @suppkey
        )
        <
        -- Global average supply cost
        (
            SELECT AVG(ps2.ps_supplycost)
            FROM dbo.partsupp ps2
        )
    );
GO


