-- P24: Customer visible if they have orders from at least 3 different suppliers
USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p23_customer_multi_supplier;
GO

CREATE FUNCTION dbo.p23_customer_multi_supplier
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
    OR
    (
        SELECT COUNT(DISTINCT l.l_suppkey)
        FROM dbo.orders o
        JOIN dbo.lineitem l
          ON l.l_orderkey = o.o_orderkey
        WHERE o.o_custkey = @custkey
    ) >= 3;
GO