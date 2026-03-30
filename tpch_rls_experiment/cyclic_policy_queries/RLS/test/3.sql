-- Disable others
ALTER SECURITY POLICY query3_orders_customer_policy_view WITH (STATE = OFF);

-- Enable RLS
ALTER SECURITY POLICY query3_orders_customer_policy_rls WITH (STATE = ON);

-- Run query
SELECT
    l.l_orderkey,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    o.o_orderdate,
    o.o_shippriority
FROM dbo.customer c
JOIN dbo.orders o ON c.c_custkey = o.o_custkey
JOIN dbo.lineitem l ON l.l_orderkey = o.o_orderkey
WHERE
    c.c_mktsegment = 'FURNITURE'
    AND o.o_orderdate < '1995-01-01'
    AND l.l_shipdate > '1995-01-01'
GROUP BY
    l.l_orderkey,
    o.o_orderdate,
    o.o_shippriority;