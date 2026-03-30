CREATE FUNCTION dbo.atomic_p8_udf(@suppkey BIGINT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN NOT EXISTS (
            SELECT 1
            FROM dbo.partsupp ps
            JOIN dbo.part p ON p.p_partkey = ps.ps_partkey
            WHERE ps.ps_suppkey = @suppkey
              AND p.p_retailprice < 500
        ) THEN 1 ELSE 0 END
    );
END
GO