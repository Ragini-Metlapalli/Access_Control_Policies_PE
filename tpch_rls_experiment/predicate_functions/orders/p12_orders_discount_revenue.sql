-- P12: orders visible if at least one lineitem has discount 5%-10% and discounted price > 1000
CREATE FUNCTION dbo.p12_orders_discount_revenue
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
    OR EXISTS
    (
        SELECT 1
        FROM dbo.lineitem l
        WHERE l.l_orderkey = @orderkey
          AND l.l_discount BETWEEN 0.05 AND 0.10
          AND l.l_extendedprice * (1 - l.l_discount) > 1000
    );
GO