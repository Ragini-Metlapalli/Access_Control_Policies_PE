ALTER SECURITY POLICY query3_orders_customer_policy_rls WITH (STATE = OFF);
ALTER SECURITY POLICY query3_orders_customer_policy_view WITH (STATE = OFF);

-- Run query with UDF
SELECT
    l.l_orderkey,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    o.o_orderdate,
    o.o_shippriority
FROM dbo.customer c
JOIN dbo.orders o ON c.c_custkey = o.o_custkey
JOIN dbo.lineitem l ON l.l_orderkey = o.o_orderkey
WHERE
    dbo.atomic_p6_udf(c.c_custkey) = 1
    AND dbo.atomic_p11_udf(o.o_orderkey) = 1
    AND c.c_mktsegment = 'FURNITURE'
    AND o.o_orderdate < '1995-01-01'
    AND l.l_shipdate > '1995-01-01'
GROUP BY
    l.l_orderkey,
    o.o_orderdate,
    o.o_shippriority;
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));
GO