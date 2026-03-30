CREATE FUNCTION dbo.atomic_p11_rls(@orderkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1
WHERE (
    SELECT SUM(l.l_extendedprice * (1 - l.l_discount))
    FROM dbo.lineitem l
    WHERE l.l_orderkey = @orderkey
) > 100000;
GO