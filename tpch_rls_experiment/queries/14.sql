SELECT
    100.00 * SUM(
        CASE
            WHEN p.p_type LIKE 'PROMO%'
            THEN l.l_extendedprice * (1 - l.l_discount)
            ELSE 0
        END
    )
    / SUM(l.l_extendedprice * (1 - l.l_discount)) AS promo_revenue
FROM
    dbo.lineitem l
JOIN
    dbo.part p
    ON l.l_partkey = p.p_partkey
WHERE
    l.l_shipdate >= '1995-09-01'
    AND l.l_shipdate < DATEADD(MONTH, 1, '1995-09-01');
