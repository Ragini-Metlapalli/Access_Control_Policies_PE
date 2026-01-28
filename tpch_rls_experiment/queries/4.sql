SELECT
    o.o_orderpriority,
    COUNT(*) AS order_count
FROM
    dbo.orders o
WHERE
    o.o_orderdate >= '1997-07-01'
    AND o.o_orderdate < DATEADD(MONTH, 3, '1997-07-01')
    AND EXISTS (
        SELECT 1
        FROM dbo.lineitem l
        WHERE
            l.l_orderkey = o.o_orderkey
            AND l.l_commitdate < l.l_receiptdate
    )
GROUP BY
    o.o_orderpriority
ORDER BY
    o.o_orderpriority;
