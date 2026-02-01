-- P42: Customer visible only if they have ordered parts from at least 3 different part brands


CREATE FUNCTION dbo.p42_customer_multi_brand_orders
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
        SELECT COUNT(DISTINCT p.p_brand)
        FROM dbo.orders o
        JOIN dbo.lineitem l
          ON l.l_orderkey = o.o_orderkey
        JOIN dbo.part p
          ON p.p_partkey = l.l_partkey
        WHERE o.o_custkey = @custkey
    ) >= 3;
GO
