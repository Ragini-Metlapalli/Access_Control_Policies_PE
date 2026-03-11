/*
Missing Index Details from 12.sql
The Query Processor estimates that implementing the following index could improve the query cost by 69.6961%.
*/

DROP INDEX IF EXISTS q12_idx ON lineitem
GO

USE [TPCH]
GO
CREATE NONCLUSTERED INDEX q12
ON [dbo].[lineitem] ([L_ShipDate],[L_CommitDate],[L_ReceiptDate],[L_ShipMode])

GO
