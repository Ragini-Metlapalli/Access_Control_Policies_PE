/*
Missing Index Details from test.sql
The Query Processor estimates that implementing the following index could improve the query cost by 17.026%.
*/

DROP INDEX IF EXISTS q8_p14_p19_p16_idx on orders
GO

USE [TPCH]
GO
CREATE NONCLUSTERED INDEX q8_p14_p19_p16_idx
ON [dbo].[orders] ([O_CustKey],[O_OrderDate])

GO

