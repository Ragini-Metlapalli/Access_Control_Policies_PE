-- P25: supplier if customer from two diff regions
CREATE FUNCTION dbo.p24_supplier_multi_region
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
    OR
    (
        SELECT COUNT(DISTINCT r.r_regionkey)
        FROM dbo.lineitem l
        JOIN dbo.orders o   ON o.o_orderkey = l.l_orderkey
        JOIN dbo.customer c ON c.c_custkey  = o.o_custkey
        JOIN dbo.nation n   ON n.n_nationkey = c.c_nationkey
        JOIN dbo.region r   ON r.r_regionkey = n.n_regionkey
        WHERE l.l_suppkey = @suppkey
    ) >= 2;
GO