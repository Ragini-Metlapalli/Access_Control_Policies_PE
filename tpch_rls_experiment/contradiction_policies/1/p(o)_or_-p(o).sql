DROP FUNCTION IF EXISTS dbo.fn_policy_wrapper;
GO

CREATE FUNCTION dbo.fn_policy_wrapper
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
    WHERE EXISTS (
        SELECT 1 FROM dbo.fn_policy_p(@o_orderstatus, @o_totalprice, @o_orderdate)
    )
    AND EXISTS (
        SELECT 1 FROM dbo.fn_policy_not_p(@o_orderstatus, @o_totalprice, @o_orderdate)
    )
);
GO