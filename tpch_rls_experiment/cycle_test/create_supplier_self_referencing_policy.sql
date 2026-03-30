DROP SECURITY POLICY supplier_rls;

CREATE SECURITY POLICY supplier_rls
ADD FILTER PREDICATE dbo.p_supplier_recursive(s_suppkey)
ON dbo.supplier
WITH (STATE = ON);
GO