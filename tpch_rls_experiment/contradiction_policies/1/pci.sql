DROP INDEX IF EXISTS idx_orders_pci ON dbo.orders;
GO

CREATE NONCLUSTERED INDEX idx_orders_pci
ON dbo.orders (
    o_orderstatus,
    o_totalprice,
    o_orderdate
);
GO