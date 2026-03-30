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
    SELECT 1
    FROM dbo.orders o
    WHERE 
        o.o_custkey = @c_custkey
        AND o.o_orderdate >= DATEADD(DAY, -30, GETDATE())
);