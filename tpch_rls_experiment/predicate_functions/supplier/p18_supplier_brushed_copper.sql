-- P18: Supplier visible if they supply at least one 'Small brushed copper' part
USE TPCH;
GO

DROP FUNCTION IF EXISTS dbo.p18_supplier_brushed_copper;
GO

CREATE FUNCTION dbo.p18_supplier_brushed_copper
(
    @suppkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR EXISTS
    (
        SELECT 1
        FROM dbo.partsupp ps
        JOIN dbo.part p
          ON p.p_partkey = ps.ps_partkey
        WHERE ps.ps_suppkey = @suppkey
          AND p.p_name = 'Small brushed copper'
    );
GO
