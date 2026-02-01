import os
import time
import random
from utils.helper import load_json, run_sql, append_csv, enrich_row
from utils.sql_parser import extract_tables
from utils.stats_parser import parse_stats

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

PREDICATES_DIR = os.path.join(ROOT, "predicates")
QUERIES_DIR = os.path.join(ROOT, "queries")
POLICY_TEMPLATE = os.path.join(ROOT, "policies/templates/policy_template.sql")

DB_CONF = load_json(os.path.join(ROOT, "config/db_config.json"))
EXP_CONF = load_json(os.path.join(ROOT, "config/experiment_config.json"))

RESULTS_FILE = EXP_CONF["output"]["results_file"]


def load_predicates_for_table(table):
    path = os.path.join(PREDICATES_DIR, table)
    if not os.path.isdir(path):
        return []
    return [
        load_json(os.path.join(path, f))
        for f in os.listdir(path)
        if f.endswith(".json")
    ]


def create_policy(pred, state):
    template = open(POLICY_TEMPLATE).read()

    sql = template.format(
        policy_name=f"{pred['table']}_rls_policy",
        predicate_name=pred["predicate_name"],
        columns=", ".join(pred["columns"]),
        table=pred["table"],
        state=state
    )

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
    random.seed(4)  

    for query_file in os.listdir(QUERIES_DIR):
        if not query_file.endswith(".sql"):
            continue

        query_sql = open(os.path.join(QUERIES_DIR, query_file)).read()
        tables = extract_tables(query_sql)

        chosen_preds = {}
        for table in tables:
            preds = load_predicates_for_table(table)
            if preds:
                chosen_preds[table] = random.choice(preds)

        for mode in EXP_CONF["modes"]:

            if mode == "WITH_RLS":
                for pred in chosen_preds.values():
                    create_policy(pred, "ON")
            else:
                for pred in chosen_preds.values():
                    create_policy(pred, "OFF")

            for run in range(1, EXP_CONF["runs_per_query"] + 1):
                output = execute_query_as_user(
                    query_sql, EXP_CONF["users_to_test"][0]
                )

                stats = parse_stats(output)

                row = {
                    "mode": mode,
                    "strategy": "NO_CARTESIAN",
                    "run_number": run,
                    "user": EXP_CONF["users_to_test"][0],
                    "policy_ids": ";".join(p["policy_id"] for p in chosen_preds.values()),
                    "predicate_functions": ";".join(p["predicate_name"] for p in chosen_preds.values()),
                    "predicate_columns": ";".join(",".join(p["columns"]) for p in chosen_preds.values()),
                    "tables_affected": ";".join(chosen_preds.keys()),
                    **stats
                }

                row = enrich_row(
                    row,
                    DB_CONF,
                    query_meta={"query_name": query_file, "tables": tables}
                )

                append_csv(RESULTS_FILE, row)
                time.sleep(EXP_CONF["execution"]["delay_between_runs_seconds"])


if __name__ == "__main__":
    main()
