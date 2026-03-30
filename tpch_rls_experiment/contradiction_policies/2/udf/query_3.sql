SELECT COUNT(*)
FROM dbo.orders
WHERE dbo.fn_policy_wrapper_udf_2(
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate
) = 1
OPTION (USE HINT('DISABLE_TSQL_SCALAR_UDF_INLINING'));