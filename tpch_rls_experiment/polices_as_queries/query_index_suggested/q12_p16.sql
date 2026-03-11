/*
Missing Index Details from test_lineitem.sql
The Query Processor estimates that implementing the following index could improve the query cost by 70.3416%.
*/

DROP INDEX IF EXISTS q12_p16_idx ON lineitem
GO

USE [TPCH]
GO
CREATE NONCLUSTERED INDEX q12_p16_idx
ON [dbo].[lineitem] ([L_ShipDate],[L_CommitDate],[L_ReceiptDate],[L_ShipMode])
INCLUDE ([L_PartKey],[L_SuppKey])
GO

