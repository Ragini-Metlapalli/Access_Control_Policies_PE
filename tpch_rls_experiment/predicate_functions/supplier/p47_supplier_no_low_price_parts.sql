-- P47: Supplier visible only if they have never supplied a part with retail price below 500


CREATE FUNCTION dbo.p47_supplier_no_low_price_parts
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
    NOT EXISTS
    (
        SELECT 1
        FROM dbo.partsupp ps
        JOIN dbo.part p
          ON p.p_partkey = ps.ps_partkey
        WHERE ps.ps_suppkey = @suppkey
          AND p.p_retailprice < 500
    );
GO
