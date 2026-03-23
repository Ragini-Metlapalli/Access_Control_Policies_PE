SELECT l.l_orderkey, s.s_name
FROM dbo.lineitem l
JOIN dbo.supplier s 
    ON l.l_suppkey = s.s_suppkey
WHERE l.l_receiptdate > l.l_commitdate;