CREATE NONCLUSTERED INDEX idx_supplier_p3b
ON dbo.supplier (s_suppkey);
GO

CREATE NONCLUSTERED INDEX idx_partsupp_p3b
ON dbo.partsupp (ps_suppkey, ps_partkey);
GO

CREATE NONCLUSTERED INDEX idx_part_p3b
ON dbo.part (p_partkey, p_retailprice);
GO