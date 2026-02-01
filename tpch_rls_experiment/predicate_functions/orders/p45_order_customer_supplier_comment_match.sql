-- P45: Orders visible only if the customer and supplier share at least one common language in comments (string-based semantic join)

CREATE FUNCTION dbo.p45_order_customer_supplier_comment_match
(
    @orderkey BIGINT,
    @custkey  BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR
    EXISTS
    (
        SELECT 1
        FROM dbo.lineitem l
        JOIN dbo.supplier s
          ON s.s_suppkey = l.l_suppkey
        JOIN dbo.customer c
          ON c.c_custkey = @custkey
        WHERE l.l_orderkey = @orderkey
          AND
          (
              LOWER(c.c_comment) LIKE '%' + LOWER(s.s_name) + '%'
              OR
              LOWER(s.s_comment) LIKE '%' + LOWER(c.c_name) + '%'
          )
    );
GO
