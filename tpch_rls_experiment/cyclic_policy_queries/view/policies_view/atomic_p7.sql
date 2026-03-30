DROP VIEW IF EXISTS dbo.v_p7_part_flag;
DROP FUNCTION IF EXISTS dbo.atomic_p7_view_fn;
GO

CREATE VIEW dbo.v_p7_part_flag
WITH SCHEMABINDING
AS
SELECT 
    l.l_partkey,
    MAX(CASE WHEN l.l_quantity > 200 THEN 1 ELSE 0 END) AS has_large_qty
FROM dbo.lineitem l
GROUP BY l.l_partkey;
GO


CREATE FUNCTION dbo.atomic_p7_view(@partkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1
FROM dbo.v_p7_part_flag v
WHERE v.l_partkey = @partkey
  AND v.has_large_qty = 0;
GO