DROP INDEX IF EXISTS idx_orders_pci_main ON dbo.orders;
GO

CREATE NONCLUSTERED INDEX idx_orders_pci_main
ON dbo.orders (
    o_orderstatus,
    o_totalprice,
    o_orderdate,
    o_custkey
);
GO