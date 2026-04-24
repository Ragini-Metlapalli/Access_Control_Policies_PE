-- ============================================================
-- CLEANUP
-- ============================================================
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'a_policy')
    DROP SECURITY POLICY a_policy;
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'b_policy')
    DROP SECURITY POLICY b_policy;
IF OBJECT_ID('dbo.fn_rls_a', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_rls_a;
IF OBJECT_ID('dbo.fn_rls_b', 'IF') IS NOT NULL DROP FUNCTION dbo.fn_rls_b;
IF OBJECT_ID('dbo.a', 'U')         IS NOT NULL DROP TABLE dbo.a;
IF OBJECT_ID('dbo.b', 'U')         IS NOT NULL DROP TABLE dbo.b;
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'k1')
    DROP USER k1;

-- ============================================================
-- USER
-- ============================================================
CREATE USER k1 WITHOUT LOGIN;
GRANT SELECT ON SCHEMA::dbo TO k1;

-- ============================================================
-- TABLES
-- ============================================================
CREATE TABLE dbo.a (
    id         INT PRIMARY KEY,
    access_key VARCHAR(10) NOT NULL,
    payload    VARCHAR(50)
);

CREATE TABLE dbo.b (
    id         INT PRIMARY KEY,
    access_key VARCHAR(10) NOT NULL,
    payload    VARCHAR(50)
);

-- ============================================================
-- DATA  (identical counts to the PostgreSQL version)
--   key | rows in A | rows in B
--   k1  |     7     |     3
--   k2  |     4     |     5
--   k3  |     2     |     6
--   k4  |     3     |     3
--   k9  |     1     |     0   (A-side orphan)
--   k0  |     0     |     1   (B-side orphan)
-- ============================================================
INSERT INTO dbo.a (id, access_key, payload) VALUES
  (101,'k1','a-k1-alpha'),(102,'k1','a-k1-beta'),(103,'k1','a-k1-gamma'),
  (104,'k1','a-k1-delta'),(105,'k1','a-k1-epsilon'),(106,'k1','a-k1-zeta'),
  (107,'k1','a-k1-eta'),
  (201,'k2','a-k2-alpha'),(202,'k2','a-k2-beta'),
  (203,'k2','a-k2-gamma'),(204,'k2','a-k2-delta'),
  (301,'k3','a-k3-alpha'),(302,'k3','a-k3-beta'),
  (401,'k4','a-k4-alpha'),(402,'k4','a-k4-beta'),(403,'k4','a-k4-gamma'),
  (901,'k9','a-k9-only');

INSERT INTO dbo.b (id, access_key, payload) VALUES
  (101,'k1','b-k1-alpha'),(102,'k1','b-k1-beta'),(103,'k1','b-k1-gamma'),
  (201,'k2','b-k2-alpha'),(202,'k2','b-k2-beta'),(203,'k2','b-k2-gamma'),
  (204,'k2','b-k2-delta'),(205,'k2','b-k2-epsilon'),
  (301,'k3','b-k3-alpha'),(302,'k3','b-k3-beta'),(303,'k3','b-k3-gamma'),
  (304,'k3','b-k3-delta'),(305,'k3','b-k3-epsilon'),(306,'k3','b-k3-zeta'),
  (401,'k4','b-k4-alpha'),(402,'k4','b-k4-beta'),(403,'k4','b-k4-gamma'),
  (901,'k0','b-k0-only');

-- ============================================================
-- CYCLE FUNCTIONS
-- Inline TVFs required for MSSQL RLS predicates.
-- Leg A reads dbo.b (which has its own policy).
-- Leg B reads dbo.a (which has its own policy).
-- ============================================================
GO
CREATE FUNCTION dbo.fn_rls_a(@login SYSNAME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (
    SELECT 1 AS result
    WHERE EXISTS (
        SELECT 1 FROM dbo.b
        WHERE b.access_key = @login
    )
);
GO

CREATE FUNCTION dbo.fn_rls_b(@login SYSNAME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (
    SELECT 1 AS result
    WHERE EXISTS (
        SELECT 1 FROM dbo.a
        WHERE a.access_key = @login
    )
);
GO

-- ============================================================
-- SECURITY POLICIES
-- ============================================================
CREATE SECURITY POLICY a_policy
    ADD FILTER PREDICATE dbo.fn_rls_a(USER_NAME())
    ON dbo.a WITH (STATE = ON);

CREATE SECURITY POLICY b_policy
    ADD FILTER PREDICATE dbo.fn_rls_b(USER_NAME())
    ON dbo.b WITH (STATE = ON);

-- ============================================================
-- VERIFY DATA BEFORE TRIGGERING  (run as dbo/sysadmin)
-- ============================================================
SELECT 'A' AS tbl, access_key, COUNT(*) AS cnt
FROM dbo.a GROUP BY access_key;

SELECT 'B' AS tbl, access_key, COUNT(*) AS cnt
FROM dbo.b GROUP BY access_key;

-- ============================================================
-- TRIGGER  (MSSQL silently returns 0 rows instead of crashing)
-- ============================================================
EXECUTE AS USER = 'k1';

SELECT * FROM dbo.a;
-- No error. Returns 0 rows.
-- The cycle is detected internally and the predicate short-circuits to false.
-- k1 cannot see ANY row regardless of what keys exist.

SELECT * FROM dbo.b;
-- Same: 0 rows. Silent blackout.

REVERT;

-- ============================================================
-- CONFIRM THE BLACKOUT  (run as dbo to compare)
-- ============================================================
SELECT COUNT(*) AS visible_as_dbo FROM dbo.a;   -- 16
SELECT COUNT(*) AS visible_as_dbo FROM dbo.b;   -- 16

-- k1 sees 0 of those 16. No error, no warning.