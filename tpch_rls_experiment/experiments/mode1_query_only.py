import os
import time
import itertools
from utils.helper import load_json, run_sql, append_csv, enrich_row
from utils.sql_parser import extract_tables
from utils.stats_parser import parse_stats

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

QUERIES_DIR = os.path.join(ROOT, "queries")
PREDICATES_DIR = os.path.join(ROOT, "predicates")
POLICY_TEMPLATE = os.path.join(ROOT, "policies/templates/policy_template.sql")

DB_CONF = load_json(os.path.join(ROOT, "config/db_config.json"))
EXP_CONF = load_json(os.path.join(ROOT, "config/experiment_config.json"))

def make_results_file(query_file, mode, policies=None):
    base = os.path.splitext(query_file)[0]  # remove .sql

    if mode == "QUERY_ONLY":
        return f"results/results_{base}.csv"

    if mode == "QUERY_WITH_POLICIES":
        policy_part = "_".join(sorted(policies))
        return f"results/results_{base}_{policy_part}.csv"


def load_predicates(table):
    path = os.path.join(PREDICATES_DIR, table)
    if not os.path.isdir(path):
        return []
    return [load_json(os.path.join(path, f)) for f in os.listdir(path) if f.endswith(".json")]


def create_policy(pred, state):
    sql = open(POLICY_TEMPLATE).read().format(
        policy_name=f"{pred['table']}_rls_policy",
        predicate_name=pred["predicate_name"],
        columns=", ".join(pred["columns"]),
        table=pred["table"],
        state=state
    )
    run_sql(sql, DB_CONF)


def run_query(query_sql, user):
    wrapped = f"""
    CHECKPOINT;
    DBCC DROPCLEANBUFFERS;
    EXECUTE AS USER = '{user}';
    SET STATISTICS IO ON;
    SET STATISTICS TIME ON;
    {query_sql}
    REVERT;
    """
    return run_sql(wrapped, DB_CONF)


def main(query_name):
    query_path = os.path.join(QUERIES_DIR, query_name)
    if not os.path.exists(query_path):
        raise FileNotFoundError(f"Query file not found: {query_name}")

    query_sql = open(query_path).read()
    tables = extract_tables(query_sql)

    results_file = make_results_file(
        query_file=query_name,
        mode="QUERY_ONLY"
    )

    table_preds = {t: load_predicates(t) for t in tables if load_predicates(t)}
    if not table_preds:
        raise RuntimeError("No predicates found for tables in query")

    combinations = list(itertools.product(*table_preds.values()))
    combinations = combinations[:EXP_CONF["rls"]["max_cartesian_combinations"]]

    for combo in combinations:

        combo_preds = list(combo)

        for mode in EXP_CONF["modes"]:
            state = "ON" if mode == "WITH_RLS" else "OFF"

            for pred in combo_preds:
                create_policy(pred, state)

            for run in range(1, EXP_CONF["runs_per_query"] + 1):
                out = run_query(query_sql, EXP_CONF["users_to_test"][0])
                stats = parse_stats(out)

                row = {
                    "mode": mode,
                    "strategy": "MODE1_CARTESIAN",
                    "run_number": run,
                    "user": EXP_CONF["users_to_test"][0],
                    "policy_ids": ";".join(p["policy_id"] for p in combo),
                    "predicate_functions": ";".join(p["predicate_name"] for p in combo),
                    "tables_affected": ";".join(p["table"] for p in combo),
                    **stats
                }

                row = enrich_row(row, DB_CONF, query_meta={
                    "query_name": query_name,
                    "tables": tables
                })

                append_csv(results_file, row)
                time.sleep(EXP_CONF["execution"]["delay_between_runs_seconds"])


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python -m experiments.mode1_query_only <query.sql>")
        exit(1)
    main(sys.argv[1])
