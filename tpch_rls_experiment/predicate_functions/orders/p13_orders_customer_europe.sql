-- P13: customer residing in europe
CREATE FUNCTION dbo.p13_orders_customer_europe
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
    OR EXISTS
    (
        SELECT 1
        FROM dbo.customer c
        JOIN dbo.nation n ON n.n_nationkey = c.c_nationkey
        JOIN dbo.region r ON r.r_regionkey = n.n_regionkey
        WHERE c.c_custkey = @custkey
          AND r.r_name = 'EUROPE'
    );
GO