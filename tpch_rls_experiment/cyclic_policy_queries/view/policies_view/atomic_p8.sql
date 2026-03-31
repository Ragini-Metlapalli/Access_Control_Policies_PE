DROP VIEW IF EXISTS dbo.v_p8_supplier_flag;
DROP FUNCTION IF EXISTS dbo.atomic_p8_view_fn;
GO

CREATE VIEW dbo.v_p8_supplier_flag
WITH SCHEMABINDING
AS
SELECT 
    ps.ps_suppkey,
    MAX(CASE WHEN p.p_retailprice < 500 THEN 1 ELSE 0 END) AS has_low_price
FROM dbo.partsupp ps
JOIN dbo.part p ON p.p_partkey = ps.ps_partkey
GROUP BY ps.ps_suppkey;
GO

CREATE FUNCTION dbo.atomic_p8_view(@suppkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
FROM dbo.v_p8_supplier_flag v
WHERE v.ps_suppkey = @suppkey
  AND v.has_low_price = 0;
GO