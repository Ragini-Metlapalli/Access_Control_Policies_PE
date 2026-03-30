DROP SECURITY POLICY IF EXISTS query12_orders_policy_view;
GO

CREATE SECURITY POLICY query12_orders_policy_view
ADD FILTER PREDICATE dbo.atomic_p11_view(o_orderkey) ON dbo.orders
WITH (STATE = ON);
GO