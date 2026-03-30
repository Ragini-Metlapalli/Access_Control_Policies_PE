DROP SECURITY POLICY IF EXISTS order_rls_policy_3;
GO

CREATE SECURITY POLICY order_rls_policy_3
ADD FILTER PREDICATE dbo.fn_policy_wrapper_3(
    o_orderkey,
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate
)
ON dbo.orders
WITH (STATE = ON);
GO