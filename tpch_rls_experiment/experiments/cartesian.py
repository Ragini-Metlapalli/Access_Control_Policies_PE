import os
import time
import itertools
from utils.helper import load_json, run_sql, append_csv, enrich_row
from utils.sql_parser import extract_tables
from utils.stats_parser import parse_stats


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
PREDICATES_DIR = os.path.join(ROOT, "predicates")
QUERIES_DIR = os.path.join(ROOT, "queries")

DB_CONF = load_json(os.path.join(ROOT, "config/db_config.json"))
EXP_CONF = load_json(os.path.join(ROOT, "config/experiment_config.json"))

RESULTS_FILE = EXP_CONF["output"]["results_file"]


def load_predicates_for_tables(tables):
    preds = []
    for table in tables:
        table_dir = os.path.join(PREDICATES_DIR, table)
        if not os.path.isdir(table_dir):
            continue

        for f in os.listdir(table_dir):
            if f.endswith(".json"):
                preds.append(load_json(os.path.join(table_dir, f)))
    return preds


def set_all_policies_off(tables):
    for table in tables:
        sql = f"""
        ALTER SECURITY POLICY dbo.{table}_rls_policy
        WITH (STATE = OFF);
        """
        run_sql(sql, DB_CONF)


def set_policy_on(table):
    sql = f"""
    ALTER SECURITY POLICY dbo.{table}_rls_policy
    WITH (STATE = ON);
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

        predicates = load_predicates_for_tables(tables)

        max_k = min(
            len(predicates),
            EXP_CONF["rls"]["max_cartesian_combinations"]
        )

        for k in range(1, max_k + 1):
            for combo in itertools.combinations(predicates, k):

                set_all_policies_off(tables)

                for pred in combo:
                    set_policy_on(pred["table"])

                for run in range(1, EXP_CONF["runs_per_query"] + 1):
                    output = execute_query_as_user(
                        query_sql, EXP_CONF["users_to_test"][0]
                    )

                    stats = parse_stats(output)

                    row = {
                        "mode": "WITH_RLS",
                        "strategy": "CARTESIAN",
                        "run_number": run,
                        "user": EXP_CONF["users_to_test"][0],
                        "policies_applied": ",".join(
                            [p["policy_id"] for p in combo]
                        ),
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

                    time.sleep(
                        EXP_CONF["execution"]["delay_between_runs_seconds"]
                    )


if __name__ == "__main__":
    main()
