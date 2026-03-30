DROP SECURITY POLICY IF EXISTS customer_rls_policy
DROP SECURITY POLICY IF EXISTS orders_rls_policy
GO

CREATE SECURITY POLICY customer_rls_policy
ADD FILTER PREDICATE dbo.fn_customer_policy(c_custkey, c_acctbal)
ON dbo.customer
WITH (STATE = ON);

CREATE SECURITY POLICY orders_rls_policy
ADD FILTER PREDICATE dbo.fn_orders_policy(o_custkey, o_totalprice, o_orderdate)
ON dbo.orders
WITH (STATE = ON);