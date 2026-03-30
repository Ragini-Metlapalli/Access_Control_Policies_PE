CREATE FUNCTION dbo.atomic_p7_rls(@partkey BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 WHERE NOT EXISTS (
    SELECT 1 FROM dbo.lineitem l
    WHERE l.l_partkey = @partkey
      AND l.l_quantity > 200
);
GO