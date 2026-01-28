-- P16: Lineitem visible if supplier sold at least 20% of this part to customers in same region as Customer#000001111
CREATE FUNCTION dbo.p16_lineitem_region_quantity
(
    @partkey   BIGINT,
    @orderkey  BIGINT,
    @quantity  INT
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
        -- Condition 1: quantity >= 20% of total quantity of this part
        @quantity >= 0.2 *
        (
            SELECT SUM(l2.l_quantity)
            FROM dbo.lineitem l2
            WHERE l2.l_partkey = @partkey
        )
        AND
        -- Condition 2: order customer region = region of customer 1111
        (
            SELECT n.n_regionkey
            FROM dbo.orders o
            JOIN dbo.customer c ON c.c_custkey = o.o_custkey
            JOIN dbo.nation n   ON n.n_nationkey = c.c_nationkey
            WHERE o.o_orderkey = @orderkey
        )
        =
        (
            SELECT n2.n_regionkey
            FROM dbo.customer c2
            JOIN dbo.nation n2 ON n2.n_nationkey = c2.c_nationkey
            WHERE c2.c_custkey = 1111
        )
    );
GO
