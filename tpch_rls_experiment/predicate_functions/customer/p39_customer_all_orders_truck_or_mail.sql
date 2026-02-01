-- P39: Customer visible only if all their orders have at least one lineitem shipped via TRUCK or MAIL


CREATE FUNCTION dbo.p39_customer_all_orders_truck_or_mail
(
    @custkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR
    NOT EXISTS
    (
        SELECT 1
        FROM dbo.orders o
        WHERE o.o_custkey = @custkey
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.lineitem l
              WHERE l.l_orderkey = o.o_orderkey
                AND l.l_shipmode IN ('TRUCK', 'MAIL')
          )
    );
GO
