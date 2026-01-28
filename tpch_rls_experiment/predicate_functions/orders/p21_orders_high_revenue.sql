-- P21: Orders visible only if total order revenue exceeds 100,000
CREATE FUNCTION dbo.p21_orders_high_revenue
(
    @orderkey BIGINT
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
        SELECT SUM(l.l_extendedprice * (1 - l.l_discount))
        FROM dbo.lineitem l
        WHERE l.l_orderkey = @orderkey
    ) > 100000;
GO