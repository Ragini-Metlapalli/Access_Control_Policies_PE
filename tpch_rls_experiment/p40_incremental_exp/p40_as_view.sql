
DROP FUNCTION IF EXISTS dbo.p40_lineitem_supplier_nation_export_gt_import;
GO


DROP VIEW IF EXISTS dbo.v_lineitem_chunk;
GO

CREATE VIEW dbo.v_lineitem_chunk
WITH SCHEMABINDING
AS
SELECT l_orderkey, l_suppkey, l_extendedprice, l_discount
FROM (
    SELECT l_orderkey, l_suppkey, l_extendedprice, l_discount,
           ROW_NUMBER() OVER (ORDER BY l_orderkey) AS row_id
    FROM dbo.lineitem
) t
WHERE row_id BETWEEN 1 AND 5000;
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
WHERE
    USER_NAME() = 'user3'
    OR
    (
        (
            -- Export value of supplier's nation
            SELECT COALESCE(SUM(lx.l_extendedprice * (1 - lx.l_discount)), 0)
            FROM dbo.v_lineitem_chunk lx   
            JOIN dbo.supplier sx
              ON sx.s_suppkey = lx.l_suppkey
            WHERE sx.s_nationkey =
                  (
                      SELECT s2.s_nationkey
                      FROM dbo.supplier s2
                      WHERE s2.s_suppkey = @suppkey
                  )
        )
        >
        (
            -- Import value of same nation
            SELECT COALESCE(SUM(ly.l_extendedprice * (1 - ly.l_discount)), 0)
            FROM dbo.v_lineitem_chunk ly   
            JOIN dbo.orders oy
              ON oy.o_orderkey = ly.l_orderkey
            JOIN dbo.customer cy
              ON cy.c_custkey = oy.o_custkey
            WHERE cy.c_nationkey =
                  (
                      SELECT s3.s_nationkey
                      FROM dbo.supplier s3
                      WHERE s3.s_suppkey = @suppkey
                  )
        )
    );
GO