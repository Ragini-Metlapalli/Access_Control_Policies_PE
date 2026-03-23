CREATE INDEX idx_l_shipdate ON dbo.lineitem(l_shipdate);
CREATE INDEX idx_l_orderkey ON dbo.lineitem(l_orderkey);

CREATE INDEX idx_o_custkey ON dbo.orders(o_custkey);

CREATE INDEX idx_c_custkey ON dbo.customer(c_custkey);