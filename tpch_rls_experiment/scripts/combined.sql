CREATE SECURITY POLICY dbo.combined
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part,
ADD FILTER PREDICATE dbo.p1_last_5y(l_shipdate) ON dbo.lineitem
WITH (STATE = ON);
GO

SELECT 
    name AS policy_name,
    is_enabled
FROM sys.security_policies  -- change name as needed
GO

