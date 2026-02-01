-- P14: balance > 1000 n living in asia
CREATE FUNCTION dbo.p14_customer_asia_balance_v2
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
        AND (
            SELECT r.r_name
            FROM dbo.nation n
            JOIN dbo.region r ON r.r_regionkey = n.n_regionkey
            WHERE n.n_nationkey = @nationkey
        ) = 'ASIA'
    );
GO

