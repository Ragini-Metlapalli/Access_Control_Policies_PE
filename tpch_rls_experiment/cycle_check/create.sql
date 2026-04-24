-- ============================================================
-- CLEAN RESET
-- ============================================================

-- Drop security policies
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'employees_policy')
    DROP SECURITY POLICY employees_policy;

IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'departments_policy')
    DROP SECURITY POLICY departments_policy;

-- Drop functions
IF OBJECT_ID('dbo.fn_rls_employees', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_rls_employees;

IF OBJECT_ID('dbo.fn_rls_departments', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_rls_departments;

-- Drop tables
IF OBJECT_ID('dbo.employees', 'U') IS NOT NULL
    DROP TABLE dbo.employees;

IF OBJECT_ID('dbo.departments', 'U') IS NOT NULL
    DROP TABLE dbo.departments;

-- Drop user
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'test_user')
    DROP USER test_user;


-- ============================================================
-- SETUP
-- ============================================================

-- Create user
CREATE USER test_user WITHOUT LOGIN;

-- Grant access
GRANT SELECT ON SCHEMA::dbo TO test_user;


-- ============================================================
-- TABLES
-- ============================================================

CREATE TABLE dbo.departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    manager_login VARCHAR(100)
);

CREATE TABLE dbo.employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    login_name VARCHAR(100)
);


-- ============================================================
-- DATA
-- ============================================================

INSERT INTO dbo.departments VALUES
(10, 'Engineering', 'alice'),
(20, 'Marketing', 'bob'),
(30, 'Finance', 'carol'),
(40, 'IT', 'test_user');

INSERT INTO dbo.employees VALUES
(1, 'Alice', 10, 'alice'),
(2, 'Bob', 20, 'bob'),
(3, 'Carol', 30, 'carol'),
(4, 'Tester', 40, 'test_user');


-- ============================================================
-- RLS FUNCTIONS 
-- ============================================================

GO
CREATE FUNCTION dbo.fn_rls_employees(@login_name SYSNAME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS result
    WHERE EXISTS (
        SELECT 1
        FROM dbo.departments d
        WHERE d.manager_login = @login_name
    )
);
GO

CREATE FUNCTION dbo.fn_rls_departments(@login_name SYSNAME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS result
    WHERE EXISTS (
        SELECT 1
        FROM dbo.employees e
        WHERE e.login_name = @login_name
    )
);
GO


-- ============================================================
-- SECURITY POLICIES
-- ============================================================

CREATE SECURITY POLICY employees_policy
ADD FILTER PREDICATE dbo.fn_rls_employees(USER_NAME())
ON dbo.employees
WITH (STATE = ON);

CREATE SECURITY POLICY departments_policy
ADD FILTER PREDICATE dbo.fn_rls_departments(USER_NAME())
ON dbo.departments
WITH (STATE = ON);


-- ============================================================
-- TEST
-- ============================================================

EXECUTE AS USER = 'test_user';

SELECT * FROM dbo.employees;

REVERT;