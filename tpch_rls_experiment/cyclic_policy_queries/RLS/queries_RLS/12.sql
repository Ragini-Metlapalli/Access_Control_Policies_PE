DROP SECURITY POLICY IF EXISTS query12_orders_policy_rls;
GO

CREATE SECURITY POLICY query12_orders_policy_rls
ADD FILTER PREDICATE dbo.atomic_p11_rls(o_orderkey) ON dbo.orders
WITH (STATE = ON);
GO