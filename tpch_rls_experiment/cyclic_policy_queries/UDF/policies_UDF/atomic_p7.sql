CREATE FUNCTION dbo.atomic_p7_udf(@partkey BIGINT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN NOT EXISTS (
            SELECT 1 FROM dbo.lineitem l
            WHERE l.l_partkey = @partkey
              AND l.l_quantity > 200
        ) THEN 1 ELSE 0 END
    );
END
GO