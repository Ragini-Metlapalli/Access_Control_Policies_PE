SELECT COUNT(*)
FROM dbo.orders
WHERE dbo.udf_fn_policy_wrapper(
    o_orderstatus,
    o_totalprice,
    o_orderdate
) = 1
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));

-- 1459131  --> customer active


-- 590032 --> orders active

--581822 --> both active


-- 1500000 --> both off
