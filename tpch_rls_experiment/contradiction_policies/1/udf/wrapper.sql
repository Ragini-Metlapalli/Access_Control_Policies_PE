DROP FUNCTION IF EXISTS dbo.udf_fn_policy_wrapper;
GO

CREATE FUNCTION dbo.udf_fn_policy_wrapper
(
    @o_orderstatus CHAR(1),
    @o_totalprice DECIMAL(15,2),
    @o_orderdate DATE
)
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;

    IF (
        dbo.udf_fn_policy_p(@o_orderstatus, @o_totalprice, @o_orderdate) = 1
        AND
        dbo.udf_fn_policy_not_p(@o_orderstatus, @o_totalprice, @o_orderdate) = 1
    )
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO