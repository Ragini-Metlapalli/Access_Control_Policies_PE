SELECT
    cntrycode,
    COUNT(*) AS numcust,
    SUM(c_acctbal) AS totacctbal
FROM (
    SELECT
        LEFT(c.c_phone, 2) AS cntrycode,
        c.c_acctbal
    FROM
        dbo.customer c
    WHERE
        LEFT(c.c_phone, 2) IN ('13','31','23','29','30','18','17')
        AND c.c_acctbal > (
            SELECT AVG(c2.c_acctbal)
            FROM dbo.customer c2
            WHERE c2.c_acctbal > 0.00
              AND LEFT(c2.c_phone, 2) IN ('13','31','23','29','30','18','17')
        )
        AND NOT EXISTS (
            SELECT 1
            FROM dbo.orders o
            WHERE o.o_custkey = c.c_custkey
        )
) AS custsale
GROUP BY
    cntrycode
ORDER BY
    cntrycode;
