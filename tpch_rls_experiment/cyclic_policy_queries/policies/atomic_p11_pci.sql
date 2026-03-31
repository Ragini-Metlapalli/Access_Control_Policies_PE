CREATE NONCLUSTERED INDEX idx_orders_p4b
ON dbo.orders (
    o_orderkey
);
GO

CREATE NONCLUSTERED INDEX idx_lineitem_p4b
ON dbo.lineitem (l_orderkey)
INCLUDE (l_extendedprice, l_discount);
GO