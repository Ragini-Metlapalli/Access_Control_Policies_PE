SELECT COUNT(*)
FROM dbo.orders
WHERE dbo.udf_fn_policy_wrapper(
    o_orderstatus,
    o_totalprice,
    o_orderdate
) = 1;