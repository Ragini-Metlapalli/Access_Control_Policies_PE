CREATE FUNCTION dbo.udf_p40_lineitem_supplier_nation_export_gt_import
(
    @suppkey BIGINT
)
RETURNS INT
AS
BEGIN
    DECLARE @allowed INT = 0;

    -- user3 always allowed
    IF USER_NAME() = 'user3'
    BEGIN
        SET @allowed = 1;
        RETURN @allowed;
    END

    DECLARE @nation_export DECIMAL(18,4) = 0;
    DECLARE @nation_import DECIMAL(18,4) = 0;

    -- Get the nation of the supplier
    DECLARE @nationkey INT;
    SELECT @nationkey = s2.s_nationkey
    FROM dbo.supplier s2
    WHERE s2.s_suppkey = @suppkey;

    -- Export value: total value of goods supplied by suppliers from that nation
    SELECT @nation_export = SUM(lx.l_extendedprice * (1 - lx.l_discount))
    FROM dbo.lineitem lx
    JOIN dbo.supplier sx
        ON sx.s_suppkey = lx.l_suppkey
    WHERE sx.s_nationkey = @nationkey;

    -- Import value: total value of goods purchased by customers from that nation
    SELECT @nation_import = SUM(ly.l_extendedprice * (1 - ly.l_discount))
    FROM dbo.lineitem ly
    JOIN dbo.orders oy
        ON oy.o_orderkey = ly.l_orderkey
    JOIN dbo.customer cy
        ON cy.c_custkey = oy.o_custkey
    WHERE cy.c_nationkey = @nationkey;

    -- Apply the policy condition
    IF @nation_export > @nation_import
    BEGIN
        SET @allowed = 1;
    END

    RETURN @allowed;
END
GO