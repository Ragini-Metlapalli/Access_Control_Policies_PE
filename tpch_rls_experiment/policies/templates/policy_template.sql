DROP SECURITY POLICY IF EXISTS dbo.{policy_name};
GO

CREATE SECURITY POLICY dbo.{policy_name}
ADD FILTER PREDICATE {predicate_name}({columns})
ON dbo.{table}
WITH (STATE = {state});
GO
