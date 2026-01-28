-- Database-level users (authorization)
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user1')
    CREATE USER user1 FOR LOGIN user1;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user2')
    CREATE USER user2 FOR LOGIN user2;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user3')
    CREATE USER user3 FOR LOGIN user3;

GO

SELECT name 
FROM sys.database_principals
WHERE name IN ('user1','user2','user3');
GO
