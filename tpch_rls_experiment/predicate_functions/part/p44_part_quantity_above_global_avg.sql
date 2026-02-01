-- P44: Part visible only if its total ordered quantity exceeds the average total quantity of all parts

CREATE FUNCTION dbo.p44_part_quantity_above_global_avg
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
        (
            -- Total quantity for this part
            SELECT SUM(l.l_quantity)
            FROM dbo.lineitem l
            WHERE l.l_partkey = @partkey
        )
        >
        (
            -- Average total quantity across all parts
            SELECT AVG(part_qty)
            FROM (
                SELECT SUM(l2.l_quantity) AS part_qty
                FROM dbo.lineitem l2
                GROUP BY l2.l_partkey
            ) t
        )
    );
GO
