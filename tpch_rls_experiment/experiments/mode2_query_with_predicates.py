import os
import time
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



def load_predicate(table, name):
    path = os.path.join(PREDICATES_DIR, table, name)
    if not os.path.exists(path):
        raise FileNotFoundError(path)
    return load_json(path)


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
    EXECUTE AS USER = '{user}';
    SET STATISTICS IO ON;
    SET STATISTICS TIME ON;
    {query_sql}
    REVERT;
    """
    return run_sql(wrapped, DB_CONF)


def main(query_name, predicate_args):
    query_path = os.path.join(QUERIES_DIR, query_name)
    if not os.path.exists(query_path):
        raise FileNotFoundError(query_name)

    query_sql = open(query_path).read()
    tables = extract_tables(query_sql)

    preds = []
    seen_tables = set()

    for arg in predicate_args:
        table, fname = arg.split(":")
        pred = load_predicate(table, fname)

        if table in seen_tables:
            raise ValueError(f"Multiple predicates for table {table}")

        seen_tables.add(table)
        preds.append(pred)

    policy_ids = [p["policy_id"] for p in preds]

    for mode in EXP_CONF["modes"]:
        state = "ON" if mode == "WITH_RLS" else "OFF"

        results_file = make_results_file(
            query_file=query_name,
            mode="QUERY_WITH_POLICIES",
            policies=policy_ids
        )

        for pred in preds:
            create_policy(pred, state)

        for run in range(1, EXP_CONF["runs_per_query"] + 1):
            out = run_query(query_sql, EXP_CONF["users_to_test"][0])
            stats = parse_stats(out)

            row = {
                "mode": mode,
                "strategy": "MODE2_EXPLICIT",
                "run_number": run,
                "user": EXP_CONF["users_to_test"][0],
                "policy_ids": ";".join(p["policy_id"] for p in preds),
                "predicate_functions": ";".join(p["predicate_name"] for p in preds),
                "tables_affected": ";".join(p["table"] for p in preds),
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
    if len(sys.argv) < 3:
        print("Usage: python -m experiments.mode2_query_with_predicates <query.sql> table:predicate.json ...")
        exit(1)
    main(sys.argv[1], sys.argv[2:])
