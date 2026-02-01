-- P50: Orders visible only if the average discount across its lineitems is strictly increasing with quantity (correlation-style policy)

CREATE FUNCTION dbo.p50_order_positive_quantity_discount_correlation
(
    @orderkey BIGINT
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
            SELECT
                AVG(l.l_quantity * l.l_discount)
                - AVG(l.l_quantity) * AVG(l.l_discount)
            FROM dbo.lineitem l
            WHERE l.l_orderkey = @orderkey
        ) > 0
    );
GO
