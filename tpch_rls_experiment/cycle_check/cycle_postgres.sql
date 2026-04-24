-- ============================================================
-- CLEANUP
-- ============================================================
DROP TABLE IF EXISTS b CASCADE;
DROP TABLE IF EXISTS a CASCADE;
DROP FUNCTION IF EXISTS fn_rls_a(TEXT);
DROP FUNCTION IF EXISTS fn_rls_b(TEXT);
DROP ROLE IF EXISTS k1;

-- ============================================================
-- ROLE
-- ============================================================
CREATE ROLE k1 LOGIN PASSWORD 'k1';

-- ============================================================
-- TABLES  (access_key is the only join column)
-- ============================================================
CREATE TABLE a (
    id         INT PRIMARY KEY,
    access_key VARCHAR(10) NOT NULL,
    payload    VARCHAR(50)
);

CREATE TABLE b (
    id         INT PRIMARY KEY,
    access_key VARCHAR(10) NOT NULL,
    payload    VARCHAR(50)
);



INSERT INTO a (id, access_key, payload) VALUES
  -- k1: 7 rows in A
  (101, 'k1', 'a-k1-alpha'),
  (102, 'k1', 'a-k1-beta'),
  (103, 'k1', 'a-k1-gamma'),
  (104, 'k1', 'a-k1-delta'),
  (105, 'k1', 'a-k1-epsilon'),
  (106, 'k1', 'a-k1-zeta'),
  (107, 'k1', 'a-k1-eta'),
  -- k2: 4 rows in A
  (201, 'k2', 'a-k2-alpha'),
  (202, 'k2', 'a-k2-beta'),
  (203, 'k2', 'a-k2-gamma'),
  (204, 'k2', 'a-k2-delta'),
  -- k3: 2 rows in A
  (301, 'k3', 'a-k3-alpha'),
  (302, 'k3', 'a-k3-beta'),
  -- k4: 3 rows in A
  (401, 'k4', 'a-k4-alpha'),
  (402, 'k4', 'a-k4-beta'),
  (403, 'k4', 'a-k4-gamma'),
  -- k9: 1 row in A, 0 in B  (orphan on A side)
  (901, 'k9', 'a-k9-only');

INSERT INTO b (id, access_key, payload) VALUES
  -- k1: 3 rows in B
  (101, 'k1', 'b-k1-alpha'),
  (102, 'k1', 'b-k1-beta'),
  (103, 'k1', 'b-k1-gamma'),
  -- k2: 5 rows in B
  (201, 'k2', 'b-k2-alpha'),
  (202, 'k2', 'b-k2-beta'),
  (203, 'k2', 'b-k2-gamma'),
  (204, 'k2', 'b-k2-delta'),
  (205, 'k2', 'b-k2-epsilon'),
  -- k3: 6 rows in B
  (301, 'k3', 'b-k3-alpha'),
  (302, 'k3', 'b-k3-beta'),
  (303, 'k3', 'b-k3-gamma'),
  (304, 'k3', 'b-k3-delta'),
  (305, 'k3', 'b-k3-epsilon'),
  (306, 'k3', 'b-k3-zeta'),
  -- k4: 3 rows in B  (equal to A side)
  (401, 'k4', 'b-k4-alpha'),
  (402, 'k4', 'b-k4-beta'),
  (403, 'k4', 'b-k4-gamma'),
  -- k0: 1 row in B, 0 in A  (orphan on B side)
  (901, 'k0', 'b-k0-only');

-- ============================================================
-- ENABLE RLS
-- ============================================================
ALTER TABLE a ENABLE ROW LEVEL SECURITY;
ALTER TABLE b ENABLE ROW LEVEL SECURITY;
ALTER TABLE a FORCE ROW LEVEL SECURITY;
ALTER TABLE b FORCE ROW LEVEL SECURITY;

-- ============================================================
-- CYCLE FUNCTIONS  (SECURITY INVOKER keeps RLS active inside)
--
-- fn_rls_a  : called by A's policy → reads B (which has RLS)
--             → B's policy calls fn_rls_b → reads A → CYCLE
--
-- fn_rls_b  : called by B's policy → reads A (which has RLS)
--             → A's policy calls fn_rls_a → reads B → CYCLE
-- ============================================================
CREATE OR REPLACE FUNCTION fn_rls_a(p_user TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM b
        WHERE b.access_key = p_user
    );
END;
$$;

CREATE OR REPLACE FUNCTION fn_rls_b(p_user TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM a
        WHERE a.access_key = p_user
    );
END;
$$;

-- ============================================================
-- GRANTS
-- ============================================================
GRANT SELECT ON a TO k1;
GRANT SELECT ON b TO k1;
GRANT EXECUTE ON FUNCTION fn_rls_a(TEXT) TO k1;
GRANT EXECUTE ON FUNCTION fn_rls_b(TEXT) TO k1;

-- ============================================================
-- POLICIES
-- ============================================================
CREATE POLICY a_policy ON a FOR ALL
    USING (fn_rls_a(current_user::TEXT));

CREATE POLICY b_policy ON b FOR ALL
    USING (fn_rls_b(current_user::TEXT));

-- ============================================================
-- VERIFY DATA BEFORE TRIGGERING  (run as superuser)
-- ============================================================
SELECT 'A totals' AS tbl, access_key, COUNT(*) AS cnt
FROM a GROUP BY access_key ORDER BY access_key;

SELECT 'B totals' AS tbl, access_key, COUNT(*) AS cnt
FROM b GROUP BY access_key ORDER BY access_key;

-- ============================================================
-- TRIGGER THE CYCLE
-- k1's access_key is 'k1' — not in data, irrelevant.
-- The cycle fires the instant any row evaluation begins.
-- ============================================================
SET ROLE k1;

SELECT * FROM a;
-- ERROR:  stack depth limit exceeded
-- HINT:  Increase the configuration parameter "max_stack_depth"

RESET ROLE;
