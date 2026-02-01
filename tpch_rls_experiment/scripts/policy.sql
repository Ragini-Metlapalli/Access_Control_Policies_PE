DROP SECURITY POLICY IF EXISTS dbo.lineitem_rls_policy
DROP SECURITY POLICY IF EXISTS dbo.orders_rls_policy
DROP SECURITY POLICY IF EXISTS dbo.customer_rls_policy;
DROP SECURITY POLICY IF EXISTS dbo.supplier_rls_policy;
DROP SECURITY POLICY IF EXISTS dbo.part_rls_policy;
GO
-- CREATE SECURITY POLICY dbo.lineitem_rls_policy
-- CREATE SECURITY POLICY dbo.orders_rls_policy
-- CREATE SECURITY POLICY dbo.customer_rls_policy
-- CREATE SECURITY POLICY dbo.supplier_rls_policy
CREATE SECURITY POLICY dbo.part_rls_policy
-- ADD FILTER PREDICATE dbo.p1_last_5y(l_shipdate) ON dbo.lineitem,
-- ADD FILTER PREDICATE dbo.p2_no_carefully(l_comment) ON dbo.lineitem,
-- ADD FILTER PREDICATE dbo.p3_return_discount(l_returnflag, l_discount) ON dbo.lineitem,
-- ADD FILTER PREDICATE dbo.p4_open_not_returned(l_linestatus, l_returnflag) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p5_price_range(l_extendedprice, l_discount) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p6_ship_commit(l_shipdate, l_commitdate) ON dbo.lineitem,
-- ADD FILTER PREDICATE dbo.p7_receipt_commit(l_receiptdate, l_commitdate) ON dbo.lineitem,
-- ADD FILTER PREDICATE dbo.p8_shipmode(l_shipmode) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p9_tax(l_tax) ON dbo.lineitem,
-- ADD FILTER PREDICATE dbo.p10_discount_quantity(l_discount, l_quantity) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p11_customer_supplier_same_region(l_orderkey, l_suppkey) on dbo.lineitem
-- ADD FILTER PREDICATE dbo.p12_orders_discount_revenue(o_orderkey) ON dbo.orders
-- ADD FILTER PREDICATE dbo.p13_orders_customer_europe(o_custkey) ON dbo.orders
-- ADD FILTER PREDICATE dbo.p14_customer_asia_balance(c_acctbal, c_nationkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p14_customer_asia_balance_v2(c_acctbal, c_nationkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p15_customer_recent_large_orders(c_custkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p16_lineitem_region_quantity(l_partkey, l_orderkey, l_quantity) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p17_customer_active_no_cancel(c_custkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p18_supplier_brushed_copper(s_suppkey) ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part
-- ADD FILTER PREDICATE dbo.p20_part_avg_supplycost(p_partkey) ON dbo.part
-- ADD FILTER PREDICATE dbo.p21_orders_high_revenue(o_orderkey) ON dbo.orders
-- ADD FILTER PREDICATE dbo.p22_orders_no_late_shipments(o_orderkey) ON dbo.orders
-- ADD FILTER PREDICATE dbo.p23_customer_multi_supplier(c_custkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p24_supplier_multi_region(s_suppkey) ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p25_lineitem_above_brand_avg_price(l_partkey) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p26_part_many_suppliers(p_partkey) ON dbo.part
-- ADD FILTER PREDICATE dbo.p27_supplier_below_global_avg_cost(s_suppkey) ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p28_orders_no_late_commit(o_orderkey) ON dbo.orders ``
-- ADD FILTER PREDICATE dbo.p29_customer_lifetime_value_gt_balance(c_custkey, c_acctbal) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p30_lineitem_cross_nation_same_region(l_suppkey, l_orderkey) ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p31_part_no_large_quantity(p_partkey) ON dbo.part
-- ADD FILTER PREDICATE dbo.p32_supplier_urgent_orders(s_suppkey) ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p33_orders_customer_above_nation_avg(o_custkey) ON dbo.orders
-- ADD FILTER PREDICATE dbo.p34_customer_multi_year_orders(c_custkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p35_lineitem_delay_above_shipmode_avg(l_shipmode,l_shipdate,l_receiptdate) ON dbo.lineitem
ADD FILTER PREDICATE dbo.p36_part_size_above_type_avg(p_partkey,p_size)ON dbo.part
-- ADD FILTER PREDICATE dbo.p37_supplier_multi_part_types(s_suppkey) ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p38_order_quantity_above_customer_avg(o_orderkey,o_custkey)ON dbo.orders
-- ADD FILTER PREDICATE dbo.p39_customer_all_orders_truck_or_mail(c_custkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p40_lineitem_supplier_nation_export_gt_import(l_suppkey)ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p41_order_quantity_variation_limited(o_orderkey)ON dbo.orders
-- ADD FILTER PREDICATE dbo.p42_customer_multi_brand_orders(c_custkey) ON dbo.customer
-- ADD FILTER PREDICATE dbo.p43_supplier_multi_part_sizes(s_suppkey) ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p44_part_quantity_above_global_avg(p_partkey)ON dbo.part
-- ADD FILTER PREDICATE dbo.p45_order_customer_supplier_comment_match(o_orderkey,o_custkey) ON dbo.orders
-- ADD FILTER PREDICATE dbo.p46_customer_non_uniform_spending(c_custkey)ON dbo.customer
-- ADD FILTER PREDICATE dbo.p47_supplier_no_low_price_parts(s_suppkey)ON dbo.supplier
-- ADD FILTER PREDICATE dbo.p48_lineitem_orderdate_closer_to_ship(l_orderkey,l_shipdate,l_receiptdate)ON dbo.lineitem
-- ADD FILTER PREDICATE dbo.p49_part_multi_nation_suppliers(p_partkey)ON dbo.part
-- ADD FILTER PREDICATE dbo.p50_order_positive_quantity_discount_correlation(o_orderkey)ON dbo.orders

WITH (STATE = ON);
GO



SELECT 
    name AS policy_name,
    is_enabled
FROM sys.security_policies  -- change name as needed
GO
