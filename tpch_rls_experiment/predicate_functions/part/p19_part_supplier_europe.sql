-- p19: part visible if at least one supplier is in europe
CREATE FUNCTION dbo.p19_part_supplier_europe
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
    OR EXISTS
    (
        SELECT 1
        FROM dbo.partsupp ps
        JOIN dbo.supplier s
          ON s.s_suppkey = ps.ps_suppkey
        JOIN dbo.nation n
          ON n.n_nationkey = s.s_nationkey
        JOIN dbo.region r
          ON r.r_regionkey = n.n_regionkey
        WHERE ps.ps_partkey = @partkey
          AND r.r_name = 'EUROPE'
    );
GO