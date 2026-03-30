DROP INDEX IF EXISTS idx_orders_exists ON dbo.orders;
GO

CREATE NONCLUSTERED INDEX idx_orders_exists
ON dbo.orders (
    o_custkey,
    o_orderstatus
);
GO