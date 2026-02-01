-- P41: Orders visible only if the maximum lineitem quantity in the order is at most twice the minimum quantity

CREATE FUNCTION dbo.p41_order_quantity_variation_limited
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
        (
            SELECT MAX(l.l_quantity)
            FROM dbo.lineitem l
            WHERE l.l_orderkey = @orderkey
        )
        <=
        2 *
        (
            SELECT MIN(l2.l_quantity)
            FROM dbo.lineitem l2
            WHERE l2.l_orderkey = @orderkey
        )
    );
GO
