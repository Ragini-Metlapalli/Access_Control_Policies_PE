--    P28: Orders visible only if no lineitem was shipped late (shipdate > commitdate)
CREATE FUNCTION dbo.p28_orders_no_late_commit
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
    OR NOT EXISTS
    (
        SELECT 1
        FROM dbo.lineitem l
        WHERE l.l_orderkey = @orderkey
          AND l.l_shipdate > l.l_commitdate
    );
GO
