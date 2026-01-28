-- P22: Orders visible only if all lineitems were shipped before receipt date
CREATE FUNCTION dbo.p22_orders_no_late_shipments
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
          AND l.l_shipdate > l.l_receiptdate
    );
GO