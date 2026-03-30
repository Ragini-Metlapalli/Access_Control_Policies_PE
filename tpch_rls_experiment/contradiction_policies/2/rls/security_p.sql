DROP SECURITY POLICY IF EXISTS order_rls_policy;
GO

CREATE SECURITY POLICY order_rls_policy
ADD FILTER PREDICATE dbo.fn_policy_wrapper(
    o_orderkey,
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate
)
ON dbo.orders
WITH (STATE = ON);
GO