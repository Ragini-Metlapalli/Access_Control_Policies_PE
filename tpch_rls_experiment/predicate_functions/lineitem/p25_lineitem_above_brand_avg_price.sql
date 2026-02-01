USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p25_lineitem_above_brand_avg_price;
GO

CREATE FUNCTION dbo.p25_lineitem_above_brand_avg_price
(
    @partkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR EXISTS
    (
        SELECT 1
        FROM dbo.part p
        JOIN (
            SELECT p_brand, AVG(p_retailprice) AS avg_brand_price
            FROM dbo.part
            GROUP BY p_brand
        ) ba
          ON ba.p_brand = p.p_brand
        WHERE p.p_partkey = @partkey
          AND p.p_retailprice > ba.avg_brand_price
    );
GO
