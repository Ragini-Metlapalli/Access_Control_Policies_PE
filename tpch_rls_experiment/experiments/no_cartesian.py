import os
import time
import random
from utils.helper import load_json, run_sql, append_csv, enrich_row
from utils.sql_parser import extract_tables
from utils.stats_parser import parse_stats


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PREDICATES_DIR = os.path.join(ROOT, "predicates")
QUERIES_DIR = os.path.join(ROOT, "queries")

DB_CONF = load_json(os.path.join(ROOT, "config/db_config.json"))
EXP_CONF = load_json(os.path.join(ROOT, "config/experiment_config.json"))

RESULTS_FILE = EXP_CONF["output"]["results_file"]


def load_predicates_for_table(table):
    table_dir = os.path.join(PREDICATES_DIR, table)
    if not os.path.isdir(table_dir):
        return []

    preds = []
    for f in os.listdir(table_dir):
        if f.endswith(".json"):
            preds.append(load_json(os.path.join(table_dir, f)))
    return preds


def set_policy_state(table, state):
    sql = f"""
    ALTER SECURITY POLICY dbo.{table}_rls_policy
    WITH (STATE = {state});
    """
    run_sql(sql, DB_CONF)


def execute_query_as_user(query_sql, user):
    wrapped = f"""
    EXECUTE AS USER = '{user}';
    SET STATISTICS IO ON;
    SET STATISTICS TIME ON;
    {query_sql}
    REVERT;
    """
    return run_sql(wrapped, DB_CONF)


def main():
    for query_file in os.listdir(QUERIES_DIR):
        if not query_file.endswith(".sql"):
            continue

        query_path = os.path.join(QUERIES_DIR, query_file)
        query_sql = open(query_path).read()
        tables = extract_tables(query_sql)

        # Step 1: pick ONE random predicate per table (ONCE per query)
        chosen_predicates = {}
        for table in tables:
            preds = load_predicates_for_table(table)
            if preds:
                chosen_predicates[table] = random.choice(preds)

        # Step 2: run experiments
        for mode in EXP_CONF["modes"]:

            # Apply policy state once per mode
            for table in tables:
                set_policy_state(table, "ON" if mode == "WITH_RLS" else "OFF")

            for run in range(1, EXP_CONF["runs_per_query"] + 1):

                output = execute_query_as_user(
                    query_sql, EXP_CONF["users_to_test"][0]
                )

                stats = parse_stats(output)

                # Collect policy metadata
                policy_ids = []
                policy_names = []
                predicate_functions = []
                predicate_columns = []
                tables_affected = []

                for table, pred in chosen_predicates.items():
                    policy_ids.append(pred["policy_id"])
                    policy_names.append(f"{table}_rls_policy")
                    predicate_functions.append(pred["predicate_name"])
                    predicate_columns.append(",".join(pred["columns"]))
                    tables_affected.append(table)

                row = {
                    "mode": mode,
                    "strategy": "NO_CARTESIAN",
                    "run_number": run,
                    "user": EXP_CONF["users_to_test"][0],
                    "policy_ids": ";".join(policy_ids),
                    "policy_names": ";".join(policy_names),
                    "predicate_functions": ";".join(predicate_functions),
                    "predicate_columns": ";".join(predicate_columns),
                    "tables_affected": ";".join(tables_affected),
                    **stats
                }

                row = enrich_row(
                    row,
                    DB_CONF,
                    query_meta={
                        "query_name": query_file,
                        "tables": tables
                    }
                )

                append_csv(RESULTS_FILE, row)

                time.sleep(EXP_CONF["execution"]["delay_between_runs_seconds"])


if __name__ == "__main__":
    main()
