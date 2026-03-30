-- Dummy policy: show lineitem row only if supplier exists for that suppkey
DROP FUNCTION IF EXISTS dbo.udf_dummy_blackbox
GO

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
        AND s.S_NationKey < 3
    )
    BEGIN
        SET @allowed = 1;
    END

    RETURN @allowed;
END
GO

-- CREATE FUNCTION dbo.udf_dummy_blackbox
-- (
--     @suppkey BIGINT
-- )
-- RETURNS INT
-- AS
-- BEGIN
--     DECLARE @allowed INT = 0;
--     DECLARE @temp BIGINT;

--     -- Force procedural logic
--     SELECT TOP 1 @temp = s.s_suppkey
--     FROM dbo.supplier s
--     WHERE s.s_suppkey = @suppkey;

--     IF (@temp IS NOT NULL)
--         SET @allowed = 1;
--     ELSE
--         SET @allowed = 0;

--     RETURN @allowed;
-- END
-- GO