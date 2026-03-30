DROP FUNCTION IF EXISTS dbo.fn_policy_wrapper_3;
GO

CREATE FUNCTION dbo.fn_policy_wrapper_3
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
        EXISTS (
                SELECT 1 FROM dbo.fn_policy_not_q_2(
                    @o_orderkey,
                    @o_custkey,
                    @o_orderstatus,
                    @o_totalprice,
                    @o_orderdate
                )
        )
        AND
        EXISTS (
            SELECT 1 FROM dbo.fn_policy_p_2(
                @o_orderkey,
                @o_custkey,
                @o_orderstatus,
                @o_totalprice,
                @o_orderdate
            )
        )
        
);
GO