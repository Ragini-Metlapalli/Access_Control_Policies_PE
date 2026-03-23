-- =========================
-- POLICY 19 (PCI)
-- =========================
CREATE INDEX idx_ps_partkey ON dbo.partsupp(ps_partkey);
CREATE INDEX idx_ps_suppkey ON dbo.partsupp(ps_suppkey);

CREATE INDEX idx_s_nationkey ON dbo.supplier(s_nationkey);

CREATE INDEX idx_n_regionkey ON dbo.nation(n_regionkey);

CREATE INDEX idx_r_name ON dbo.region(r_name);


-- =========================
-- POLICY 40 (PCI)
-- =========================
CREATE INDEX idx_l_suppkey ON dbo.lineitem(l_suppkey);
CREATE INDEX idx_l_orderkey ON dbo.lineitem(l_orderkey);

CREATE INDEX idx_c_nationkey ON dbo.customer(c_nationkey);

CREATE INDEX idx_o_custkey ON dbo.orders(o_custkey);