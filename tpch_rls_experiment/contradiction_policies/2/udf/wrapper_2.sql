-- ~q(o) & p(o)
DROP FUNCTION IF EXISTS dbo.fn_policy_wrapper_udf_2;
GO

CREATE FUNCTION dbo.fn_policy_wrapper_udf_2
(
    @o_custkey INT,
    @o_orderstatus CHAR(1),
    @o_totalprice DECIMAL(15,2),
    @o_orderdate DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;

    IF (
        dbo.fn_policy_not_q_udf_3(
            @o_custkey,
            @o_orderstatus,
            @o_totalprice,
            @o_orderdate
        ) = 1
        AND
        dbo.fn_policy_p_udf_3(
            @o_custkey,
            @o_orderstatus,
            @o_totalprice,
            @o_orderdate
        ) = 1
    )
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO