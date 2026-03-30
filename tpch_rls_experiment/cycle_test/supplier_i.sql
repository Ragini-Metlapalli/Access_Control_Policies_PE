

-- Policy on lineitem: references supplier
CREATE POLICY lineitem_policy ON lineitem
  USING (
    l_suppkey IN (
      SELECT s_suppkey FROM supplier WHERE s_nationkey = 1
    )
  );

-- Policy on supplier: references lineitem (creates the cycle)
CREATE POLICY supplier_policy ON supplier
  USING (
    s_suppkey IN (
      SELECT l_suppkey FROM lineitem WHERE l_quantity > 10
    )
  );