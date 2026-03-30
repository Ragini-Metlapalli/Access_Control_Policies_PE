DROP SECURITY POLICY IF EXISTS query3_orders_customer_policy_rls;
GO

CREATE SECURITY POLICY query3_orders_customer_policy_rls
ADD FILTER PREDICATE dbo.atomic_p11_rls(o_orderkey) ON dbo.orders,
ADD FILTER PREDICATE dbo.atomic_p6_rls(c_custkey) ON dbo.customer
WITH (STATE = ON);
GO