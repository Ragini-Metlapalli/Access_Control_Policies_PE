SELECT *
FROM dbo.lineitem l
WHERE dbo.udf_p40_lineitem(l.l_suppkey) = 1;