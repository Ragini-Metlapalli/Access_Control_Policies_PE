WITH revenue_stream AS (
    SELECT
        l.l_suppkey AS supplier_no,
        SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
    FROM dbo.lineitem l
    WHERE
        l.l_shipdate >= '1996-01-01'
        AND l.l_shipdate < DATEADD(MONTH, 3, '1996-01-01')
    GROUP BY
        l.l_suppkey
)
SELECT
    s.s_suppkey,
    s.s_name,
    s.s_address,
    s.s_phone,
    r.total_revenue
FROM dbo.supplier s
JOIN revenue_stream r
    ON s.s_suppkey = r.supplier_no
WHERE
    r.total_revenue = (
        SELECT MAX(total_revenue)
        FROM revenue_stream
    )
ORDER BY
    s.s_suppkey;
