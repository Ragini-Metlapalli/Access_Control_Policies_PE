-- P46: Customer visible only if the variance of their order revenues is greater than zero (i.e., non-uniform spending behavior)

CREATE FUNCTION dbo.p46_customer_non_uniform_spending
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
        SELECT COUNT(DISTINCT l.l_extendedprice * (1 - l.l_discount))
        FROM dbo.orders o
        JOIN dbo.lineitem l
          ON l.l_orderkey = o.o_orderkey
        WHERE o.o_custkey = @custkey
    ) > 1;
GO
