DROP SECURITY POLICY IF EXISTS query3_orders_customer_policy_view;
GO

CREATE SECURITY POLICY query3_orders_customer_policy_view
ADD FILTER PREDICATE dbo.atomic_p11_view(o_orderkey) ON dbo.orders,
ADD FILTER PREDICATE dbo.atomic_p6_view(c_custkey) ON dbo.customer
WITH (STATE = ON);
GO