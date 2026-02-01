-- P15: Customer visible if any order in last 90 days has lineitem quantity > 100
USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p15_customer_recent_large_orders;
GO

CREATE FUNCTION dbo.p15_customer_recent_large_orders
(
    @custkey BIGINT
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
        FROM dbo.orders o
        JOIN dbo.lineitem l
          ON l.l_orderkey = o.o_orderkey
        WHERE o.o_custkey = @custkey
          AND o.o_orderdate >= DATEADD(DAY, -90, CAST(GETDATE() AS DATE))
          AND l.l_quantity > 100
    );
GO