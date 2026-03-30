DROP SECURITY POLICY IF EXISTS dbo.test_cycle;

CREATE SECURITY POLICY dbo.test_cycle
ADD FILTER PREDICATE dbo.p_lineitem_test(l_suppkey) ON dbo.lineitem,
ADD FILTER PREDICATE dbo.p_supplier_test(s_suppkey) ON dbo.supplier
WITH (STATE = ON);
GO