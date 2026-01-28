-- Server-level logins (authentication)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'user1')
    CREATE LOGIN user1 WITH PASSWORD = 'User1@123', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'user2')
    CREATE LOGIN user2 WITH PASSWORD = 'User2@123', CHECK_POLICY = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'user3')
    CREATE LOGIN user3 WITH PASSWORD = 'User3@123', CHECK_POLICY = OFF;
GO


SELECT name 
FROM sys.server_principals
WHERE name IN ('user1','user2','user3');
GO

