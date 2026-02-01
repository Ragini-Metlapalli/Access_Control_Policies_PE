-- P36: Part visible only if its size is above the average size of parts of the same type

CREATE FUNCTION dbo.p36_part_size_above_type_avg
(
    @partkey BIGINT,
    @size    INT
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
        @size >
        (
            SELECT AVG(p2.p_size)
            FROM dbo.part p2
            WHERE p2.p_type =
            (
                SELECT p3.p_type
                FROM dbo.part p3
                WHERE p3.p_partkey = @partkey
            )
        )
    );
GO
