-- P32: Supplier visible only if they have at least one order with priority '1-URGENT'

CREATE FUNCTION dbo.p32_supplier_urgent_orders
(
    @suppkey BIGINT
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
        JOIN dbo.orders o
          ON o.o_orderkey = l.l_orderkey
        WHERE l.l_suppkey = @suppkey
          AND o.o_orderpriority = '1-URGENT'
    );
GO
