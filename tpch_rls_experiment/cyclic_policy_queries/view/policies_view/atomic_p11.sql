DROP VIEW IF EXISTS dbo.v_p11_orders_sum;
DROP FUNCTION IF EXISTS dbo.atomic_p11_view_fn;
GO


CREATE VIEW dbo.v_p11_orders_sum
WITH SCHEMABINDING
AS
SELECT 
    l.l_orderkey,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM dbo.lineitem l
GROUP BY l.l_orderkey;
GO


CREATE FUNCTION dbo.atomic_p11_view(@orderkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
FROM dbo.v_p11_orders_sum v
WHERE v.l_orderkey = @orderkey
  AND v.total_revenue > 100000;
GO