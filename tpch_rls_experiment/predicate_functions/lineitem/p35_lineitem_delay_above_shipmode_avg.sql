-- P35: Lineitem visible only if its shipping delay exceeds the average delay for that ship mode
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
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR
    (
        DATEDIFF(DAY, @shipdate, @receiptdate)
        >
        (
            SELECT AVG(DATEDIFF(DAY, l2.l_shipdate, l2.l_receiptdate))
            FROM dbo.lineitem l2
            WHERE l2.l_shipmode = @shipmode
        )
    );
GO
