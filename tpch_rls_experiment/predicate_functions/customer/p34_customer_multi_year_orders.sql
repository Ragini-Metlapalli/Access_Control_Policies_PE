--    P34: Customer visible only if they placed orders in more than one calendar year


CREATE FUNCTION dbo.p34_customer_multi_year_orders
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
        SELECT COUNT(DISTINCT YEAR(o.o_orderdate))
        FROM dbo.orders o
        WHERE o.o_custkey = @custkey
    ) > 1;
GO
