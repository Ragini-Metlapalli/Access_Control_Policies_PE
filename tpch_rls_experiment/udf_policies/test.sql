SELECT *
FROM dbo.lineitem l
WHERE dbo.udf_p40_inline_off(l.l_suppkey) = 1