------------------------------------------------------------
-- 4. ENABLE STATS (optional but useful)
------------------------------------------------------------
SET STATISTICS IO ON;
SET STATISTICS TIME ON;


-- SELECT 
--     c.c_custkey,
--     c.c_acctbal,
--     o.o_orderkey,
--     o.o_totalprice,
--     o.o_orderdate
-- FROM dbo.customer c
-- JOIN dbo.orders o
--     ON c.c_custkey = o.o_custkey
-- WHERE c.c_acctbal < o.o_totalprice AND o.o_orderdate > CAST('1996-12-31' AS DATE)
-- ORDER BY o.o_orderdate;




------------------------------------------------------------
-- 6. RUN WITH RLS = ON
------------------------------------------------------------

PRINT '--- RLS STATE = ON ---';

ALTER SECURITY POLICY customer_rls_policy WITH (STATE = ON);
-- ALTER SECURITY POLICY orders_rls_policy   WITH (STATE = ON);

SELECT 
    c.c_custkey,
    c.c_acctbal,
    o.o_orderkey,
    o.o_totalprice,
    o.o_orderdate
FROM dbo.customer c
JOIN dbo.orders o
    ON c.c_custkey = o.o_custkey;
-- WHERE c.c_acctbal > 0;

------------------------------------------------------------
-- 7. RUN WITH RLS = OFF
------------------------------------------------------------
PRINT '--- RLS STATE = OFF ---';

ALTER SECURITY POLICY customer_rls_policy WITH (STATE = OFF);
-- ALTER SECURITY POLICY orders_rls_policy   WITH (STATE = OFF);

SELECT 
    c.c_custkey,
    c.c_acctbal,
    o.o_orderkey,
    o.o_totalprice,
    o.o_orderdate
FROM dbo.customer c
JOIN dbo.orders o
    ON c.c_custkey = o.o_custkey;
-- WHERE c.c_acctbal > 0;


-- SELECT TOP 10 * from dbo.orders;