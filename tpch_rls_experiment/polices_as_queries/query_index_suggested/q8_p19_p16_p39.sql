/*
Missing Index Details from test.sql
The Query Processor estimates that implementing the following index could improve the query cost by 15.7945%.
*/

DROP INDEX IF EXISTS q8_p19_p16_p39_idx on orders
GO
 
USE [TPCH]
GO
CREATE NONCLUSTERED INDEX q8_p19_p16_p39_idx
ON [dbo].[orders] ([O_OrderDate])
INCLUDE ([O_CustKey])
GO

