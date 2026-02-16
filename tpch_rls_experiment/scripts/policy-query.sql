SET STATISTICS XML ON;
GO

--p48
-- SELECT l.*
-- FROM dbo.lineitem l
-- JOIN dbo.orders o
--     ON o.o_orderkey = l.l_orderkey
-- CROSS APPLY (
--     SELECT
--         ABS(DATEDIFF(DAY, o.o_orderdate, l.l_shipdate))  AS ship_diff,
--         ABS(DATEDIFF(DAY, o.o_orderdate, l.l_receiptdate)) AS receipt_diff
-- ) d
-- WHERE d.ship_diff < d.receipt_diff;


--p24
-- SELECT 
--     s.s_suppkey,
--     s.s_name,
--     s.s_address,
--     s.s_nationkey,
--     s.s_phone,
--     s.s_acctbal,
--     s.s_comment
-- FROM dbo.supplier s
-- JOIN dbo.lineitem l 
--     ON l.l_suppkey = s.s_suppkey
-- JOIN dbo.orders o 
--     ON o.o_orderkey = l.l_orderkey
-- JOIN dbo.customer c 
--     ON c.c_custkey = o.o_custkey
-- JOIN dbo.nation n 
--     ON n.n_nationkey = c.c_nationkey
-- JOIN dbo.region r 
--     ON r.r_regionkey = n.n_regionkey
-- GROUP BY 
--     s.s_suppkey,
--     s.s_name,
--     s.s_address,
--     s.s_nationkey,
--     s.s_phone,
--     s.s_acctbal,
--     s.s_comment
-- HAVING COUNT(DISTINCT r.r_regionkey) >= 2;


--p19
-- SELECT DISTINCT p.*
-- FROM dbo.part p
-- JOIN dbo.partsupp ps 
--     ON ps.ps_partkey = p.p_partkey
-- JOIN dbo.supplier s 
--     ON s.s_suppkey = ps.ps_suppkey
-- JOIN dbo.nation n 
--     ON n.n_nationkey = s.s_nationkey
-- JOIN dbo.region r 
--     ON r.r_regionkey = n.n_regionkey
-- WHERE r.r_name = 'EUROPE';


--p39
-- SELECT c.*
-- FROM dbo.customer c
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM dbo.orders o
--     WHERE o.o_custkey = c.c_custkey
--       AND NOT EXISTS (
--           SELECT 1
--           FROM dbo.lineitem l
--           WHERE l.l_orderkey = o.o_orderkey
--             AND l.l_shipmode IN ('TRUCK', 'MAIL')
--       )
-- );


--P12
-- SELECT DISTINCT o.*
-- FROM orders o
-- JOIN lineitem l ON l.l_orderkey = o.o_orderkey
-- WHERE l.l_discount BETWEEN 0.05 AND 0.10
--   AND l.l_extendedprice * (1 - l.l_discount) > 1000;


--P14
SELECT c.*
FROM customer c
JOIN nation n ON n.n_nationkey = c.c_nationkey
JOIN region r ON r.r_regionkey = n.n_regionkey
WHERE c.c_acctbal > 1000
  AND r.r_name = 'ASIA';


--p15
-- SELECT DISTINCT c.*
-- FROM customer c
-- JOIN orders o ON o.o_custkey = c.c_custkey
-- JOIN lineitem l ON l.l_orderkey = o.o_orderkey
-- WHERE o.o_orderdate >= DATEADD(DAY, -90, CAST(GETDATE() AS DATE))
--   AND l.l_quantity > 100;

