DROP FUNCTION IF EXISTS fn_customer_policy
GO

CREATE FUNCTION dbo.fn_customer_policy 
(
    @c_custkey INT, 
    @c_acctbal DECIMAL(15,2)
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    FROM dbo.orders o
    WHERE 
        o.o_custkey = @c_custkey
        AND @c_acctbal < o.o_totalprice
        AND o.o_orderdate > CAST('1996-12-31' AS DATE)
);