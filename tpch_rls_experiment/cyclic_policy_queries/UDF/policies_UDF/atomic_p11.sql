CREATE FUNCTION dbo.atomic_p11_udf(@orderkey BIGINT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN (
            SELECT SUM(l.l_extendedprice * (1 - l.l_discount))
            FROM dbo.lineitem l
            WHERE l.l_orderkey = @orderkey
        ) > 100000 THEN 1 ELSE 0 END
    );
END
GO