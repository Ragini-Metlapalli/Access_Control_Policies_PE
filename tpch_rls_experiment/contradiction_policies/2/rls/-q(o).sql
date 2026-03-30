DROP FUNCTION IF EXISTS dbo.fn_policy_not_q;
GO

CREATE FUNCTION dbo.fn_policy_not_q
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
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.fn_policy_q(
            @o_orderkey,
            @o_custkey,
            @o_orderstatus,
            @o_totalprice,
            @o_orderdate
        )
    )
);
GO