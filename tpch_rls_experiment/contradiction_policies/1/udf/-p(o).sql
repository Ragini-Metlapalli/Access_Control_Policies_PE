DROP FUNCTION IF EXISTS dbo.udf_fn_policy_not_p;
GO

CREATE FUNCTION dbo.udf_fn_policy_not_p
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
        @o_orderstatus <> 'F'
        AND @o_totalprice <= 100000
        AND @o_orderdate < '1995-01-01'
    )
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO