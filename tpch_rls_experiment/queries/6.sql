SELECT
    SUM(l_extendedprice * l_discount) AS revenue
FROM
    dbo.lineitem
WHERE
    l_shipdate >= '1994-01-01'
    AND l_shipdate < DATEADD(YEAR, 1, '1994-01-01')
    AND l_discount BETWEEN 0.06 - 0.01 AND 0.06 + 0.01
    AND l_quantity < 24;
