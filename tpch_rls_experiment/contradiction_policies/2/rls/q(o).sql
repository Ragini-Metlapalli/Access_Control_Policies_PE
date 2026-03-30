DROP FUNCTION IF EXISTS dbo.fn_policy_q;
GO

CREATE FUNCTION dbo.fn_policy_q
(
    @o_orderkey INT,
    @o_custkey INT,
    @o_orderstatus CHAR(1),
    @o_totalprice DECIMAL(15,2),
    @o_orderdate DATE
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    WHERE 
        @o_totalprice > 50000
        AND @o_orderdate > '1993-12-31'
        AND EXISTS (
            SELECT 1
            FROM dbo.orders o2
            WHERE 
                o2.o_custkey = @o_custkey
                AND o2.o_orderstatus = 'F'
        )
);
GO