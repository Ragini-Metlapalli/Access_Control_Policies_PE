CREATE FUNCTION dbo.atomic_p8_rls(@suppkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.partsupp ps
    JOIN dbo.part p ON p.p_partkey = ps.ps_partkey
    WHERE ps.ps_suppkey = @suppkey
      AND p.p_retailprice < 500
);
GO