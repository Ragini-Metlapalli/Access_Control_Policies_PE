CREATE NONCLUSTERED INDEX idx_customer_p2c
ON dbo.customer (c_custkey, c_nationkey);
GO

CREATE NONCLUSTERED INDEX idx_orders_p2c
ON dbo.orders (o_custkey, o_orderkey);
GO

CREATE NONCLUSTERED INDEX idx_lineitem_p2c
ON dbo.lineitem (l_orderkey, l_suppkey);
GO

CREATE NONCLUSTERED INDEX idx_supplier_p2c
ON dbo.supplier (s_suppkey, s_nationkey);
GO

CREATE NONCLUSTERED INDEX idx_nation_p2c
ON dbo.nation (n_nationkey, n_regionkey);
GO

