DROP FUNCTION IF EXISTS dbo.p35_lineitem_delay_above_shipmode_avg;
GO

CREATE FUNCTION dbo.p35_lineitem_delay_above_shipmode_avg
(
    @shipmode     VARCHAR(20),
    @shipdate     DATE,
    @receiptdate  DATE
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN

WITH avg_delay AS (
    SELECT 
        l_shipmode,
        AVG(DATEDIFF(DAY, l_shipdate, l_receiptdate)) AS avg_delay
    FROM dbo.lineitem
    GROUP BY l_shipmode
)

SELECT 1 AS allowed
FROM avg_delay ad
WHERE 
    ad.l_shipmode = @shipmode
    AND (
        USER_NAME() = 'user3'
        OR DATEDIFF(DAY, @shipdate, @receiptdate) > ad.avg_delay
    );
GO