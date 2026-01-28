-- P14: balance > 1000 n living in asia
CREATE FUNCTION dbo.p14_customer_asia_balance
(
    @acctbal   DECIMAL(15,2),
    @nationkey INT
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
        @acctbal > 1000
        AND EXISTS
        (
            SELECT 1
            FROM dbo.nation n
            JOIN dbo.region r
              ON r.r_regionkey = n.n_regionkey
            WHERE n.n_nationkey = @nationkey
              AND r.r_name = 'ASIA'
        )
    );
GO