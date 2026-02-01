-- P26: Part visible only if supplied by more than 5 suppliers.

USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p26_part_many_suppliers;
GO

CREATE FUNCTION dbo.p26_part_many_suppliers
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
        SELECT COUNT(DISTINCT ps.ps_suppkey)
        FROM dbo.partsupp ps
        WHERE ps.ps_partkey = @partkey
    ) > 5;
GO
