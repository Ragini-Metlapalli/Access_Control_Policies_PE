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

WITH supp_nation AS (
    -- Get supplier's nation only once
    SELECT s.s_nationkey
    FROM dbo.supplier s
    WHERE s.s_suppkey = @suppkey
),

export_value AS (
    -- Total export from that nation
    SELECT SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_export
    FROM dbo.lineitem l
    JOIN dbo.supplier s
        ON s.s_suppkey = l.l_suppkey
    JOIN supp_nation sn
        ON s.s_nationkey = sn.s_nationkey
),

import_value AS (
    -- Total import into that nation
    SELECT SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_import
    FROM dbo.lineitem l
    JOIN dbo.orders o
        ON o.o_orderkey = l.l_orderkey
    JOIN dbo.customer c
        ON c.c_custkey = o.o_custkey
    JOIN supp_nation sn
        ON c.c_nationkey = sn.s_nationkey
)

SELECT 1 AS allowed
FROM export_value ev, import_value iv
WHERE 
    USER_NAME() = 'user3'
    OR ev.total_export > iv.total_import;
GO