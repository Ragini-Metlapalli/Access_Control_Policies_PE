DECLARE @brand VARCHAR(20) = 'Brand#52';
DECLARE @container VARCHAR(20) = 'LG CAN';

SELECT
    SUM(l_extendedprice) / 7.0 AS avg_yearly
FROM
    dbo.lineitem,
    dbo.part,
    (
        SELECT
            l_partkey AS agg_partkey,
            0.2 * AVG(l_quantity) AS avg_quantity
        FROM dbo.lineitem
        GROUP BY l_partkey
    ) part_agg
WHERE
    p_partkey = l_partkey
    AND agg_partkey = l_partkey
    AND p_brand = @brand
    AND p_container = @container
    AND l_quantity < avg_quantity;
