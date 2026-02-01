-- P38: Orders visible only if total quantity ordered exceeds 3× the customer’s average order quantity

CREATE FUNCTION dbo.p38_order_quantity_above_customer_avg
(
    @orderkey BIGINT,
    @custkey  BIGINT
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
        (
            SELECT SUM(l.l_quantity)
            FROM dbo.lineitem l
            WHERE l.l_orderkey = @orderkey
        )
        >
        3 *
        (
            SELECT AVG(l2.l_quantity)
            FROM dbo.orders o2
            JOIN dbo.lineitem l2
              ON l2.l_orderkey = o2.o_orderkey
            WHERE o2.o_custkey = @custkey
        )
    );
GO
