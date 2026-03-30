DROP SECURITY POLICY IF EXISTS query17_part_policy_rls;
GO

CREATE SECURITY POLICY query17_part_policy_rls
ADD FILTER PREDICATE dbo.atomic_p7_rls(p_partkey) ON dbo.part
WITH (STATE = ON);
GO