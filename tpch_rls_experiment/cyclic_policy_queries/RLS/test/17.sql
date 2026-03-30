-- Disable others
ALTER SECURITY POLICY query17_part_policy_view WITH (STATE = OFF);

-- Enable RLS
ALTER SECURITY POLICY query17_part_policy_rls WITH (STATE = ON);

SELECT SUM(l.l_extendedprice) / 7.0 AS avg_yearly
FROM dbo.lineitem l
JOIN dbo.part p ON p.p_partkey = l.l_partkey
WHERE
    p.p_brand = 'Brand#53'
    AND p.p_container = 'MED BAG'
    AND l.l_quantity < (
        SELECT 0.7 * AVG(l2.l_quantity)
        FROM dbo.lineitem l2
        WHERE l2.l_partkey = p.p_partkey
    );

GO