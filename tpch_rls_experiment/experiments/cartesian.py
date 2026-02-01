import os
import time
import itertools
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
    for query_file in os.listdir(QUERIES_DIR):
        if not query_file.endswith(".sql"):
            continue

        query_sql = open(os.path.join(QUERIES_DIR, query_file)).read()
        tables = extract_tables(query_sql)

        # predicates per table
        table_preds = {
            table: load_predicates_for_table(table)
            for table in tables
            if load_predicates_for_table(table)
        }

        # Cartesian product across tables
        combos = list(itertools.product(*table_preds.values()))
        combos = combos[:EXP_CONF["rls"]["max_cartesian_combinations"]]

        for combo in combos:

            for mode in EXP_CONF["modes"]:
                state = "ON" if mode == "WITH_RLS" else "OFF"

                for pred in combo:
                    create_policy(pred, state)

                for run in range(1, EXP_CONF["runs_per_query"] + 1):
                    output = execute_query_as_user(
                        query_sql,
                        EXP_CONF["users_to_test"][0]
                    )

                    stats = parse_stats(output)

                    row = {
                        "mode": mode,
                        "strategy": "CARTESIAN",
                        "run_number": run,
                        "user": EXP_CONF["users_to_test"][0],
                        "policy_ids": ";".join(p["policy_id"] for p in combo),
                        "predicate_functions": ";".join(p["predicate_name"] for p in combo),
                        "predicate_columns": ";".join(",".join(p["columns"]) for p in combo),
                        "tables_affected": ";".join(p["table"] for p in combo),
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
