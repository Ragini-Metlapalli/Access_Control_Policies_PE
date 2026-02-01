-- P40: Lineitem visible only if its supplier’s nation has higher total export value than import value


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
            SELECT SUM(lx.l_extendedprice * (1 - lx.l_discount))
            FROM dbo.lineitem lx
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
            SELECT SUM(ly.l_extendedprice * (1 - ly.l_discount))
            FROM dbo.lineitem ly
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
