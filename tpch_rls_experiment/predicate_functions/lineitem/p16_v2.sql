CREATE FUNCTION dbo.p16_lineitem_supplier_region_share
(
    @suppkey BIGINT,
    @partkey BIGINT
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
        /* Numerator:
           supplier+part lineitems sold to customers
           in the same region as Customer#000001111
        */
        (
            SELECT COUNT(*)
            FROM dbo.lineitem li
            JOIN dbo.orders   o ON li.l_orderkey = o.o_orderkey
            JOIN dbo.customer c ON o.o_custkey   = c.c_custkey
            JOIN dbo.nation   n ON c.c_nationkey = n.n_nationkey
            WHERE li.l_suppkey = @suppkey
              AND li.l_partkey = @partkey
              AND n.n_regionkey =
                  (
                      SELECT n2.n_regionkey
                      FROM dbo.customer c2
                      JOIN dbo.nation n2
                        ON n2.n_nationkey = c2.c_nationkey
                      WHERE c2.c_custkey = 1111
                  )
        )
        >=
        /* Denominator:
           total supplier+part lineitems
        */
        0.20 *
        (
            SELECT COUNT(*)
            FROM dbo.lineitem li2
            WHERE li2.l_suppkey = @suppkey
              AND li2.l_partkey = @partkey
        )
    );
GO
