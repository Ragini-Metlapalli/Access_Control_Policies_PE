DROP FUNCTION IF EXISTS dbo.fn_policy_p_udf_3;
GO

CREATE FUNCTION dbo.fn_policy_p_udf_3
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
        @o_totalprice > 150000
        AND @o_orderstatus = 'F'
        AND @o_orderdate > '1994-12-31'
        AND EXISTS (
            SELECT 1
            FROM dbo.orders o2
            WHERE 
                o2.o_custkey = @o_custkey
                AND o2.o_orderstatus = 'F'
        )
    )
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO