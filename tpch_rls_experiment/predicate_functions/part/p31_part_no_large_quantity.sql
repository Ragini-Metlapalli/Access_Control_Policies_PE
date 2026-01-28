-- P31: Part visible only if it has never been ordered in quantities greater than 200


CREATE FUNCTION dbo.p31_part_no_large_quantity
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
    OR NOT EXISTS
    (
        SELECT 1
        FROM dbo.lineitem l
        WHERE l.l_partkey = @partkey
          AND l.l_quantity > 200
    );
GO
