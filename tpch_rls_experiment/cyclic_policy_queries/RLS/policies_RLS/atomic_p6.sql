CREATE FUNCTION dbo.atomic_p6_rls(@custkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE EXISTS (
    SELECT 1
    FROM dbo.orders o
    JOIN dbo.lineitem l ON l.l_orderkey = o.o_orderkey
    JOIN dbo.supplier s ON s.s_suppkey = l.l_suppkey
    JOIN dbo.nation ns ON ns.n_nationkey = s.s_nationkey
    JOIN dbo.customer c ON c.c_custkey = @custkey
    JOIN dbo.nation nc ON nc.n_nationkey = c.c_nationkey
    WHERE o.o_custkey = @custkey
      AND ns.n_regionkey = nc.n_regionkey
      AND ns.n_nationkey <> nc.n_nationkey
);
GO