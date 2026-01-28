  --  P30: Lineitem visible only if supplier and customer are from different nations but same region


CREATE FUNCTION dbo.p30_lineitem_cross_nation_same_region
(
    @suppkey  BIGINT,
    @orderkey BIGINT
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
        -- supplier nation != customer nation
        (
            SELECT s.s_nationkey
            FROM dbo.supplier s
            WHERE s.s_suppkey = @suppkey
        )
        <>
        (
            SELECT c.c_nationkey
            FROM dbo.orders o
            JOIN dbo.customer c
              ON c.c_custkey = o.o_custkey
            WHERE o.o_orderkey = @orderkey
        )

        AND

        -- supplier region = customer region
        (
            SELECT n.n_regionkey
            FROM dbo.supplier s
            JOIN dbo.nation n
              ON n.n_nationkey = s.s_nationkey
            WHERE s.s_suppkey = @suppkey
        )
        =
        (
            SELECT n2.n_regionkey
            FROM dbo.orders o2
            JOIN dbo.customer c2
              ON c2.c_custkey = o2.o_custkey
            JOIN dbo.nation n2
              ON n2.n_nationkey = c2.c_nationkey
            WHERE o2.o_orderkey = @orderkey
        )
    );
GO
