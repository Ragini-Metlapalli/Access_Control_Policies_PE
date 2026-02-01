-- P48: Lineitem visible only if its order date is closer to ship date than to receipt date

CREATE FUNCTION dbo.p48_lineitem_orderdate_closer_to_ship
(
    @orderkey     BIGINT,
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
        ABS(
            DATEDIFF(
                DAY,
                (SELECT o.o_orderdate
                 FROM dbo.orders o
                 WHERE o.o_orderkey = @orderkey),
                @shipdate
            )
        )
        <
        ABS(
            DATEDIFF(
                DAY,
                (SELECT o2.o_orderdate
                 FROM dbo.orders o2
                 WHERE o2.o_orderkey = @orderkey),
                @receiptdate
            )
        )
    );
GO
