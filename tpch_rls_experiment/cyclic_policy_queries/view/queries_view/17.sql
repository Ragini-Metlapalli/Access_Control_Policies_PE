DROP SECURITY POLICY IF EXISTS query17_part_policy_view;
GO

CREATE SECURITY POLICY query17_part_policy_view
ADD FILTER PREDICATE dbo.atomic_p7_view(p_partkey) ON dbo.part
WITH (STATE = ON);
GO