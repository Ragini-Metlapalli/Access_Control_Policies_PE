-- P17: customer with no cancelled orders and at least 5 orders in last 365 days
CREATE FUNCTION dbo.p17_customer_active_no_cancel
(
    @custkey BIGINT
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
        -- Condition 1: at least 5 orders
        (
            SELECT COUNT(*)
            FROM dbo.orders o
            WHERE o.o_custkey = @custkey
        ) >= 5

        AND

        -- Condition 2: most recent order within last 365 days
        (
            SELECT MAX(o.o_orderdate)
            FROM dbo.orders o
            WHERE o.o_custkey = @custkey
        ) >= DATEADD(DAY, -365, CAST(GETDATE() AS DATE))

        AND

        -- Condition 3: zero cancelled orders
        (
            SELECT SUM(
                       CASE
                           WHEN o.o_orderstatus = 'C' THEN 1
                           ELSE 0
                       END
                   )
            FROM dbo.orders o
            WHERE o.o_custkey = @custkey
        ) = 0
    );
GO