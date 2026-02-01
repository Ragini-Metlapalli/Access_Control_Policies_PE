
-- P20: Part visible if average supply cost < 50
USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p20_part_avg_supplycost;
GO

CREATE FUNCTION dbo.p20_part_avg_supplycost
(
    @partkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR
    (
        SELECT AVG(ps.ps_supplycost)
        FROM dbo.partsupp ps
        WHERE ps.ps_partkey = @partkey
    ) < 50;
GO