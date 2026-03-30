DROP VIEW IF EXISTS dbo.v_nation_trade_final;
DROP VIEW IF EXISTS dbo.v_nation_trade_summary;
GO

-- create view
CREATE VIEW dbo.v_nation_trade_summary
WITH SCHEMABINDING
AS
-- Export per nation
SELECT 
    s.s_nationkey AS nationkey,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_export,
    CAST(0 AS FLOAT) AS total_import
FROM dbo.lineitem l
JOIN dbo.supplier s 
    ON s.s_suppkey = l.l_suppkey
GROUP BY s.s_nationkey

UNION ALL

-- Import per nation
SELECT 
    c.c_nationkey AS nationkey,
    CAST(0 AS FLOAT) AS total_export,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_import
FROM dbo.lineitem l
JOIN dbo.orders o 
    ON o.o_orderkey = l.l_orderkey
JOIN dbo.customer c 
    ON c.c_custkey = o.o_custkey
GROUP BY c.c_nationkey;
GO

-- aggregate
CREATE VIEW dbo.v_nation_trade_final
WITH SCHEMABINDING
AS
SELECT 
    nationkey,
    SUM(total_export) AS total_export,
    SUM(total_import) AS total_import
FROM dbo.v_nation_trade_summary
GROUP BY nationkey;
GO

DROP FUNCTION IF EXISTS dbo.p40_lineitem_supplier_nation_export_gt_import;
GO

CREATE FUNCTION dbo.p40_lineitem_supplier_nation_export_gt_import
(
    @suppkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN

SELECT 1 AS allowed
FROM dbo.supplier s
JOIN dbo.v_nation_trade_final v
    ON s.s_nationkey = v.nationkey
WHERE 
    s.s_suppkey = @suppkey
    AND (
        USER_NAME() = 'user3'
        OR COALESCE(v.total_export,0) > COALESCE(v.total_import,0)
    );
GO

