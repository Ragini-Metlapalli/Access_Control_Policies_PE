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

-- Get supplier nation once
CROSS APPLY (
    SELECT s.s_nationkey AS nationkey
) sn

-- Compute export once
CROSS APPLY (
    SELECT SUM(lx.l_extendedprice * (1 - lx.l_discount)) AS total_export
    FROM dbo.lineitem lx
    JOIN dbo.supplier sx ON sx.s_suppkey = lx.l_suppkey
    WHERE sx.s_nationkey = sn.nationkey
) ev

-- Compute import once
CROSS APPLY (
    SELECT SUM(ly.l_extendedprice * (1 - ly.l_discount)) AS total_import
    FROM dbo.lineitem ly
    JOIN dbo.orders o ON o.o_orderkey = ly.l_orderkey
    JOIN dbo.customer c ON c.c_custkey = o.o_custkey
    WHERE c.c_nationkey = sn.nationkey
) iv

WHERE 
    s.s_suppkey = @suppkey
    AND (
        USER_NAME() = 'user3'
        OR ev.total_export > iv.total_import
    );
GO