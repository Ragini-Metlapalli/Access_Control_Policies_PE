DROP FUNCTION IF EXISTS dbo.fn_policy_p;
GO

CREATE FUNCTION dbo.fn_policy_p
(
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
        @o_orderstatus = 'F'
        AND @o_totalprice > 100000
        AND @o_orderdate >= '1995-01-01'
);
GO