"""
RLS Binary Search Automation
==============================
- Rebuilds v_lineitem_chunk + policy p40 for each iteration
- Runs Query 21 with a hard 60-second server-side KILL on timeout
- If query times out  -> treat as "too slow" -> bisect DOWN
- If query completes  -> record time         -> bisect UP
- Prints timestamped progress at every step
- Saves all results to dbo.rls_timing_results

Requirements:
    pip install pyodbc

Usage:
    python rls_bisect.py

Edit the CONFIG block below before running.
"""

import pyodbc
import threading
import time
import sys
from datetime import datetime


def log(msg: str, indent: int = 0):
    """Print a timestamped line immediately."""
    ts = datetime.now().strftime("%H:%M:%S.%f")[:-3]
    prefix = "  " * indent
    print(f"[{ts}] {prefix}{msg}", flush=True)


# ============================================================
SERVER        = "localhost,1433"          # e.g. "myserver.database.windows.net"
DATABASE      = "tpch"           # your database name
USERNAME      = "sa"         # SQL login
PASSWORD      = "Saniya@2005"     # SQL password
TIMEOUT_SEC   = 180                  # kill query if it exceeds this
TOTAL_ROWS    = 6_001_215           # total rows in lineitem
# ============================================================



P40_TVF_BODY = """\
CREATE FUNCTION dbo.p40_lineitem_supplier_nation_export_gt_import
(
    @suppkey BIGINT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
SELECT 1 AS allowed
WHERE
    USER_NAME() = 'user3'
    OR
    (
        (
            SELECT COALESCE(SUM(lx.l_extendedprice * (1 - lx.l_discount)), 0)
            FROM dbo.v_lineitem_chunk lx
            JOIN dbo.supplier sx ON sx.s_suppkey = lx.l_suppkey
            WHERE sx.s_nationkey =
                  (SELECT s2.s_nationkey FROM dbo.supplier s2
                   WHERE s2.s_suppkey = @suppkey)
        )
        >
        (
            SELECT COALESCE(SUM(ly.l_extendedprice * (1 - ly.l_discount)), 0)
            FROM dbo.v_lineitem_chunk ly
            JOIN dbo.orders oy  ON oy.o_orderkey = ly.l_orderkey
            JOIN dbo.customer cy ON cy.c_custkey = oy.o_custkey
            WHERE cy.c_nationkey =
                  (SELECT s3.s_nationkey FROM dbo.supplier s3
                   WHERE s3.s_suppkey = @suppkey)
        )
    )"""

QUERY_21 = """\
SELECT
    s.s_name,
    COUNT(*) AS numwait
FROM
    dbo.supplier s,
    dbo.lineitem l1,
    dbo.orders   o,
    dbo.nation   n
WHERE
    s.s_suppkey        = l1.l_suppkey
    AND o.o_orderkey   = l1.l_orderkey
    AND o.o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND EXISTS (
        SELECT 1 FROM dbo.lineitem l2
        WHERE l2.l_orderkey = l1.l_orderkey
          AND l2.l_suppkey <> l1.l_suppkey
    )
    AND NOT EXISTS (
        SELECT 1 FROM dbo.lineitem l3
        WHERE l3.l_orderkey = l1.l_orderkey
          AND l3.l_suppkey <> l1.l_suppkey
          AND l3.l_receiptdate > l3.l_commitdate
    )
    AND s.s_nationkey  = n.n_nationkey
    AND n.n_name       = 'INDIA'
GROUP BY s.s_name
ORDER BY numwait DESC, s.s_name"""


# ──────────────────────────────────────────────────────────────
# CONNECTION HELPERS
# ──────────────────────────────────────────────────────────────

def get_conn(timeout=30, label=""):
    tag = f" ({label})" if label else ""
    log(f"opening DB connection{tag}  query_timeout={timeout}s", indent=2)
    t0 = time.perf_counter()
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={SERVER};DATABASE={DATABASE};"
        f"UID={USERNAME};PWD={PASSWORD};"
        f"Connection Timeout=30;"
    )
    conn = pyodbc.connect(conn_str)
    conn.timeout = timeout
    log(f"connected in {time.perf_counter()-t0:.2f}s", indent=2)
    return conn


def get_spid(conn) -> int:
    cur = conn.cursor()
    cur.execute("SELECT @@SPID")
    spid = cur.fetchone()[0]
    cur.close()
    return spid


def kill_spid(spid: int):
    """
    Open a separate connection and issue KILL <spid>.
    This makes SQL Server immediately roll back the query and
    release all locks, so the next DDL step never hangs.
    """
    log(f"issuing KILL {spid} ...", indent=2)
    try:
        kconn = get_conn(timeout=10, label="KILL")
        kconn.autocommit = True
        kcur = kconn.cursor()
        kcur.execute(f"KILL {spid}")
        kcur.close()
        kconn.close()
        log(f"KILL {spid} sent — session terminated", indent=2)
    except Exception as e:
        # Session may have ended on its own between timeout detection and KILL
        log(f"KILL {spid} note: {e}", indent=2)


# ──────────────────────────────────────────────────────────────
# REBUILD VIEW + POLICY
# ──────────────────────────────────────────────────────────────

def rebuild_policy(window_hi: int):
    log(f"REBUILD  window=1..{window_hi:,}", indent=1)
    conn = get_conn(timeout=0, label="DDL")
    conn.autocommit = True
    cur = conn.cursor()

    ddl_steps = [
        (
            "DROP SECURITY POLICY q21_p19_p40",
            "IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'q21_p19_p40') "
            "DROP SECURITY POLICY dbo.q21_p19_p40"
        ),
        (
            "DROP FUNCTION p40_lineitem_supplier_nation_export_gt_import",
            "IF OBJECT_ID('dbo.p40_lineitem_supplier_nation_export_gt_import','IF') IS NOT NULL "
            "DROP FUNCTION dbo.p40_lineitem_supplier_nation_export_gt_import"
        ),
        (
            "DROP VIEW v_lineitem_chunk",
            "IF OBJECT_ID('dbo.v_lineitem_chunk','V') IS NOT NULL "
            "DROP VIEW dbo.v_lineitem_chunk"
        ),
        (
            f"CREATE VIEW v_lineitem_chunk (rows 1..{window_hi:,})",
            f"""CREATE VIEW dbo.v_lineitem_chunk WITH SCHEMABINDING AS
SELECT l_orderkey, l_suppkey, l_extendedprice, l_discount
FROM (
    SELECT l_orderkey, l_suppkey, l_extendedprice, l_discount,
           ROW_NUMBER() OVER (ORDER BY l_orderkey) AS row_id
    FROM dbo.lineitem
) t
WHERE row_id BETWEEN 1 AND {window_hi}"""
        ),
        (
            "CREATE FUNCTION p40_lineitem_supplier_nation_export_gt_import",
            P40_TVF_BODY
        ),
        (
            "CREATE SECURITY POLICY q21_p19_p40",
            """CREATE SECURITY POLICY dbo.q21_p19_p40
ADD FILTER PREDICATE dbo.p19_part_supplier_europe(p_partkey) ON dbo.part,
ADD FILTER PREDICATE dbo.p40_lineitem_supplier_nation_export_gt_import(l_suppkey) ON dbo.lineitem
WITH (STATE = ON)"""
        ),
    ]

    for label, sql in ddl_steps:
        log(f"DDL  {label} ...", indent=2)
        t0 = time.perf_counter()
        cur.execute(sql)
        log(f"     done in {time.perf_counter()-t0:.2f}s", indent=2)

    cur.close()
    conn.close()
    log("REBUILD complete", indent=1)


# ──────────────────────────────────────────────────────────────
# RUN QUERY 21  (hard kill on timeout)
# ──────────────────────────────────────────────────────────────

def run_query21(window_hi: int):
    """
    Run Q21 in a background thread.
    If it doesn't finish within TIMEOUT_SEC, KILL the server session
    so all locks are released immediately and the next DDL won't hang.
    """
    log(f"QUERY 21  window=1..{window_hi:,}  timeout={TIMEOUT_SEC}s", indent=1)

    conn = get_conn(timeout=0, label="Q21")   # no Python-side timeout
    conn.autocommit = True

    spid = get_spid(conn)
    log(f"Q21 running on spid={spid}", indent=2)

    result = {"rows": None, "error": None}
    t0 = time.perf_counter()

    def _run():
        try:
            log("executing query ...", indent=2)
            cur = conn.cursor()
            cur.execute(QUERY_21)
            log("query sent — fetching rows ...", indent=2)
            result["rows"] = cur.fetchall()
            log(f"all rows fetched  ({len(result['rows'])} result rows)", indent=2)
            cur.close()
        except Exception as e:
            result["error"] = e

    thread = threading.Thread(target=_run, daemon=True)
    thread.start()
    thread.join(timeout=TIMEOUT_SEC)

    elapsed = time.perf_counter() - t0

    if thread.is_alive():
        # Query still running after timeout — hard kill on the server
        log(f"timeout reached at {elapsed:.1f}s — killing spid {spid}", indent=2)
        kill_spid(spid)
        thread.join(timeout=15)          # wait for thread to unblock after kill
        elapsed = time.perf_counter() - t0
        log(f"TIMED OUT  total_elapsed={elapsed:.1f}s", indent=2)
        timed_out = True
    else:
        timed_out = False
        if result["error"] is not None:
            err = result["error"]
            err_str = str(err).lower()
            # A kill from a *previous* iteration arriving late is still a timeout
            if any(k in err_str for k in ("killed", "hyt00", "timeout", "cancelled", "abort")):
                log(f"query killed/cancelled: {err}", indent=2)
                timed_out = True
            else:
                log(f"query error: {err}", indent=2)
                raise err
        else:
            log(f"Q21 completed in {elapsed:.3f}s", indent=2)

    try:
        conn.close()
    except Exception:
        pass

    return elapsed, timed_out


# ──────────────────────────────────────────────────────────────
# RESULTS TABLE
# ──────────────────────────────────────────────────────────────

def ensure_results_table():
    log("ensuring dbo.rls_timing_results table exists ...")
    conn = get_conn(timeout=0, label="setup")
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute("""
        IF OBJECT_ID('dbo.rls_timing_results', 'U') IS NULL
        CREATE TABLE dbo.rls_timing_results (
            run_id       INT IDENTITY(1,1) PRIMARY KEY,
            run_ts       DATETIME2    DEFAULT SYSUTCDATETIME(),
            iteration    INT          NOT NULL,
            chunk_lo     BIGINT       NOT NULL,
            chunk_hi     BIGINT       NOT NULL,
            elapsed_sec  FLOAT        NOT NULL,
            timed_out    BIT          NOT NULL,
            bisect_dir   NVARCHAR(10) NOT NULL
        )
    """)
    cur.close()
    conn.close()
    log("results table ready")


def save_result(iteration, chunk_hi, elapsed_sec, timed_out, bisect_dir):
    log(f"saving  iter={iteration}  rows={chunk_hi:,}  {elapsed_sec:.3f}s  dir={bisect_dir}", indent=2)
    conn = get_conn(timeout=0, label="save")
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO dbo.rls_timing_results "
        "(iteration, chunk_lo, chunk_hi, elapsed_sec, timed_out, bisect_dir) "
        "VALUES (?, 1, ?, ?, ?, ?)",
        iteration, chunk_hi, elapsed_sec, 1 if timed_out else 0, bisect_dir
    )
    cur.close()
    conn.close()
    log("saved", indent=2)


# ──────────────────────────────────────────────────────────────
# BINARY SEARCH DRIVER
# ──────────────────────────────────────────────────────────────

def fmt_time(sec, timed_out):
    return f">{TIMEOUT_SEC}s (TIMEOUT)" if timed_out else f"{sec:.3f}s"


def print_header():
    print()
    print("=" * 80)
    print(f"  RLS BINARY SEARCH   threshold={TIMEOUT_SEC}s   total_rows={TOTAL_ROWS:,}")
    print("=" * 80)
    print(f"  {'ITER':<5} {'WINDOW (1..N)':<16} {'TIME':<22} {'ACTION'}")
    print("-" * 80)


def print_row(it, mid, elapsed, timed_out, action):
    print(f"  {it:<5} {mid:<16,} {fmt_time(elapsed, timed_out):<22} {action}", flush=True)


def bisect():
    ensure_results_table()
    print_header()

    lo, hi   = 1, TOTAL_ROWS
    best_hi  = None
    best_sec = None
    results  = []
    iteration = 0

    while lo <= hi:
        iteration += 1
        mid = (lo + hi) // 2

        log("=" * 60)
        log(f"ITERATION {iteration}  testing window=1..{mid:,}  (lo={lo:,}  hi={hi:,})")

        rebuild_policy(mid)
        elapsed, timed_out = run_query21(mid)

        if timed_out or elapsed > TIMEOUT_SEC:
            direction = "DOWN"
            action    = f"TIMEOUT -> bisect DOWN  new hi={mid-1:,}"
            hi        = mid - 1
        else:
            direction = "UP"
            action    = f"OK      -> bisect UP    new lo={mid+1:,}  [best so far]"
            best_hi   = mid
            best_sec  = elapsed
            lo        = mid + 1

        log(f"DECISION  {action}")
        print_row(iteration, mid, elapsed, timed_out, action)
        save_result(iteration, mid, elapsed, timed_out, direction)
        results.append((iteration, mid, elapsed, timed_out, direction))

    # ── Final summary ─────────────────────────────────────────
    log("BINARY SEARCH COMPLETE")
    print("-" * 80)
    if best_hi is None:
        print(f"  No window completed under {TIMEOUT_SEC}s threshold.")
    else:
        print(f"  Largest window under {TIMEOUT_SEC}s:  1..{best_hi:,} rows")
        print(f"  Q21 time at that window: {best_sec:.3f}s")
    print("=" * 80)
    print()

    # Full results table
    print(f"  {'ITER':<5} {'ROWS (window)':<16} {'ELAPSED (s)':<14} {'TIMED OUT':<11} DIR")
    print("  " + "-" * 52)
    for it, mid, elapsed, to, direction in results:
        t_str = f">{TIMEOUT_SEC}" if to else f"{elapsed:.3f}"
        print(f"  {it:<5} {mid:<16,} {t_str:<14} {'YES' if to else 'no':<11} {direction}")
    print()
    print("  All results saved to dbo.rls_timing_results")


if __name__ == "__main__":
    log(f"Starting  server={SERVER}  db={DATABASE}  threshold={TIMEOUT_SEC}s")
    try:
        bisect()
    except KeyboardInterrupt:
        print("\n  Interrupted.")
        sys.exit(0)
    except Exception as e:
        log(f"FATAL: {e}")
        raise