-- Dummy policy: show lineitem row only if supplier exists for that suppkey
CREATE FUNCTION dbo.udf_dummy_blackbox
(
    @suppkey BIGINT
)
RETURNS INT
WITH INLINE = OFF        -- black box enforced
AS
BEGIN
    DECLARE @allowed INT = 0;

    IF EXISTS (
        SELECT 1
        FROM dbo.supplier s
        WHERE s.s_suppkey = @suppkey
    )
    BEGIN
        SET @allowed = 1;
    END

    RETURN @allowed;
END
GO