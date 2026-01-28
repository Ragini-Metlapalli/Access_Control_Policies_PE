-- P11: Orders with same customer region and supplier region
CREATE FUNCTION dbo.p11_customer_supplier_same_region
(
    @orderkey BIGINT,
    @suppkey  BIGINT
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
        -- Customer region
        (
            SELECT nc.n_regionkey
            FROM dbo.orders o
            JOIN dbo.customer c ON c.c_custkey = o.o_custkey
            JOIN dbo.nation nc ON nc.n_nationkey = c.c_nationkey
            WHERE o.o_orderkey = @orderkey
        )
        =
        -- Supplier region
        (
            SELECT ns.n_regionkey
            FROM dbo.supplier s
            JOIN dbo.nation ns ON ns.n_nationkey = s.s_nationkey
            WHERE s.s_suppkey = @suppkey
        )
    );
GO