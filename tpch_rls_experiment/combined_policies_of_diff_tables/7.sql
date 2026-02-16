DROP SECURITY POLICY IF EXISTS dbo.lineitem_rls_policy
DROP SECURITY POLICY IF EXISTS dbo.orders_rls_policy
DROP SECURITY POLICY IF EXISTS dbo.customer_rls_policy;
DROP SECURITY POLICY IF EXISTS dbo.supplier_rls_policy;
DROP SECURITY POLICY IF EXISTS dbo.part_rls_policy;
DROP SECURITY POLICY IF EXISTS dbo.q7_P19_P16_P39;
DROP SECURITY POLICY IF EXISTS dbo.q7_P19_P40_P39; 
DROP SECURITY POLICY IF EXISTS dbo.q7_P19_P35_P39;
DROP SECURITY POLICY IF EXISTS dbo.q7_P19_P16_P14;
DROP SECURITY POLICY IF EXISTS dbo.q7_P19_P40_P14;
DROP SECURITY POLICY IF EXISTS dbo.q7_P19_P35_P14;
GO

CREATE SECURITY POLICY dbo.q7_P19_P16_P39
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
ADD FILTER PREDICATE dbo.p16_lineitem_region_quantity(l_partkey, l_orderkey, l_quantity) ON dbo.lineitem
ADD FILTER PREDICATE dbo.p39_customer_all_orders_truck_or_mail(c_custkey) ON dbo.customer
WITH (STATE = ON);
GO


CREATE SECURITY POLICY dbo.q7_P19_P40_P39
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
ADD FILTER PREDICATE dbo.p40_lineitem_supplier_nation_export_gt_import(l_suppkey)ON dbo.lineitem
ADD FILTER PREDICATE dbo.p39_customer_all_orders_truck_or_mail(c_custkey) ON dbo.customer
WITH (STATE = ON);
GO


CREATE SECURITY POLICY dbo.q7_P19_P35_P39
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
ADD FILTER PREDICATE dbo.p35_lineitem_delay_above_shipmode_avg(l_shipmode,l_shipdate,l_receiptdate) ON dbo.lineitem
ADD FILTER PREDICATE dbo.p39_customer_all_orders_truck_or_mail(c_custkey) ON dbo.customer
WITH (STATE = ON);
GO


CREATE SECURITY POLICY dbo.q7_P19_P16_P14
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
ADD FILTER PREDICATE dbo.p16_lineitem_region_quantity(l_partkey, l_orderkey, l_quantity) ON dbo.lineitem
ADD FILTER PREDICATE dbo.p14_customer_asia_balance_v2(c_acctbal, c_nationkey) ON dbo.customer
WITH (STATE = ON);
GO


CREATE SECURITY POLICY dbo.q7_P19_P40_P14
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
ADD FILTER PREDICATE dbo.p40_lineitem_supplier_nation_export_gt_import(l_suppkey)ON dbo.lineitem
ADD FILTER PREDICATE dbo.p14_customer_asia_balance_v2(c_acctbal, c_nationkey) ON dbo.customer
WITH (STATE = ON);
GO


CREATE SECURITY POLICY dbo.q7_P19_P35_P14
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
ADD FILTER PREDICATE dbo.p35_lineitem_delay_above_shipmode_avg(l_shipmode,l_shipdate,l_receiptdate) ON dbo.lineitem
ADD FILTER PREDICATE dbo.p14_customer_asia_balance_v2(c_acctbal, c_nationkey) ON dbo.customer
WITH (STATE = ON);
GO
