DROP VIEW IF EXISTS dbo.v_p6_customer_flag;
DROP FUNCTION IF EXISTS dbo.atomic_p6_view_fn;
GO

CREATE VIEW dbo.v_p6_customer_flag
WITH SCHEMABINDING
AS
SELECT 
    o.o_custkey,
    COUNT_BIG(*) AS valid_pairs
FROM dbo.orders o
JOIN dbo.lineitem l ON l.l_orderkey = o.o_orderkey
JOIN dbo.supplier s ON s.s_suppkey = l.l_suppkey
JOIN dbo.nation ns ON ns.n_nationkey = s.s_nationkey
JOIN dbo.customer c ON c.c_custkey = o.o_custkey
JOIN dbo.nation nc ON nc.n_nationkey = c.c_nationkey
WHERE ns.n_regionkey = nc.n_regionkey
  AND ns.n_nationkey <> nc.n_nationkey
GROUP BY o.o_custkey;
GO


CREATE FUNCTION dbo.atomic_p6_view(@custkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1
FROM dbo.v_p6_customer_flag v
WHERE v.o_custkey = @custkey
  AND v.valid_pairs > 0;
GO