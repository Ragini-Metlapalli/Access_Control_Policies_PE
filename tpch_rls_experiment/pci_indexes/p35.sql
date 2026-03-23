-- P35 Policy Coverage Indexes
CREATE INDEX idx_l_shipmode ON dbo.lineitem(l_shipmode);
CREATE INDEX idx_l_shipdate ON dbo.lineitem(l_shipdate);
CREATE INDEX idx_l_receiptdate ON dbo.lineitem(l_receiptdate);