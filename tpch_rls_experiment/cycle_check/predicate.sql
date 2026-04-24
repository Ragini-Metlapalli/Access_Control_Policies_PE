-- Function for Employees: looks up allowed depts FROM Departments table
-- (Departments table is also RLS-protected → cycle leg 1)
CREATE FUNCTION dbo.fn_rls_Employees(@LoginName NVARCHAR(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_result
    FROM dbo.Departments d          -- ← queries Departments (which has its own RLS)
    WHERE d.ManagerLogin = @LoginName
       OR @LoginName = 'admin@company.com';


-- Function for Departments: looks up manager from Employees table
-- (Employees table is also RLS-protected → cycle leg 2)
CREATE FUNCTION dbo.fn_rls_Departments(@LoginName NVARCHAR(100))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_result
    FROM dbo.Employees e            -- ← queries Employees (which has its own RLS)
    WHERE e.LoginName = @LoginName
       OR @LoginName = 'admin@company.com';