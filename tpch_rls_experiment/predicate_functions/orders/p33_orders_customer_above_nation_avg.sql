-- P33: Orders visible only if placed by customers with above-average account balance in their nation

CREATE FUNCTION dbo.p33_orders_customer_above_nation_avg
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
        SELECT c.c_acctbal
        FROM dbo.customer c
        WHERE c.c_custkey = @custkey
    )
    >
    (
        SELECT AVG(c2.c_acctbal)
        FROM dbo.customer c2
        WHERE c2.c_nationkey =
        (
            SELECT c3.c_nationkey
            FROM dbo.customer c3
            WHERE c3.c_custkey = @custkey
        )
    );
GO
