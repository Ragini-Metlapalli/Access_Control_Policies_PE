--  P29: Customer visible if their lifetime total order value exceeds their account balance
CREATE FUNCTION dbo.p29_customer_lifetime_value_gt_balance
(
    @custkey  BIGINT,
    @acctbal  DECIMAL(15,2)
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
        SELECT SUM(l.l_extendedprice * (1 - l.l_discount))
        FROM dbo.orders o
        JOIN dbo.lineitem l
          ON l.l_orderkey = o.o_orderkey
        WHERE o.o_custkey = @custkey
    ) > @acctbal;
GO
