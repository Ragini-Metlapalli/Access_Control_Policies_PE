CREATE FUNCTION dbo.udf_p40_inline_off
(
    @suppkey BIGINT
)
RETURNS INT
WITH INLINE = OFF
AS
BEGIN
    DECLARE @allowed INT = 0;

    IF USER_NAME() = 'user3'
    BEGIN
        SET @allowed = 1;
        RETURN @allowed;
    END

    DECLARE @nationkey INT;
    DECLARE @nation_export DECIMAL(18,4) = 0;
    DECLARE @nation_import DECIMAL(18,4) = 0;

    SELECT @nationkey = s2.s_nationkey
    FROM dbo.supplier s2
    WHERE s2.s_suppkey = @suppkey;

    SELECT @nation_export = SUM(lx.l_extendedprice * (1 - lx.l_discount))
    FROM dbo.lineitem lx
    JOIN dbo.supplier sx
        ON sx.s_suppkey = lx.l_suppkey
    WHERE sx.s_nationkey = @nationkey;

    SELECT @nation_import = SUM(ly.l_extendedprice * (1 - ly.l_discount))
    FROM dbo.lineitem ly
    JOIN dbo.orders oy
        ON oy.o_orderkey = ly.l_orderkey
    JOIN dbo.customer cy
        ON cy.c_custkey = oy.o_custkey
    WHERE cy.c_nationkey = @nationkey;

    IF @nation_export > @nation_import
        SET @allowed = 1;

    RETURN @allowed;
END
GO