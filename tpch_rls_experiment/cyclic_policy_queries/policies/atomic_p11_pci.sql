CREATE NONCLUSTERED INDEX idx_orders_p4b
ON dbo.orders (
    o_orderkey,
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate,
    o_orderpriority,
    o_clerk,
    o_shippriority,
    o_comment
);
GO

CREATE NONCLUSTERED INDEX idx_lineitem_p4b
ON dbo.lineitem (l_orderkey)
INCLUDE (l_extendedprice, l_discount);
GO