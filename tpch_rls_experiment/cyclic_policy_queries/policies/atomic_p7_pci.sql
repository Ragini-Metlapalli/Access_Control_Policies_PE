CREATE NONCLUSTERED INDEX idx_part_p3a
ON dbo.part (p_partkey);
GO

CREATE NONCLUSTERED INDEX idx_lineitem_p3a
ON dbo.lineitem (l_partkey, l_quantity);
GO