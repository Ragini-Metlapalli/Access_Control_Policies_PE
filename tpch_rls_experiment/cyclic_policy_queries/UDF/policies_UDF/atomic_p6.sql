CREATE FUNCTION dbo.atomic_p6_udf(@custkey BIGINT)
RETURNS BIT
AS
BEGIN
    RETURN (
        SELECT CASE WHEN EXISTS (
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
        ) THEN 1 ELSE 0 END
    );
END
GO