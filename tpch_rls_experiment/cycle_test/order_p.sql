
CREATE FUNCTION dbo.fn_orders_policy 
(
    @o_custkey INT, 
    @o_totalprice DECIMAL(15,2), 
    @o_orderdate DATE
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    FROM dbo.customer c
    WHERE 
        c.c_custkey = @o_custkey
);