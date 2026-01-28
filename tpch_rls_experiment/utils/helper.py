import json
import subprocess
import csv
import os
from datetime import datetime
from pathlib import Path


def load_json(path):
    """
    Load a JSON file and return Python dict
    """
    with open(path, "r") as f:
        return json.load(f)


def run_sql(sql_text, db_conf):
    """
    Execute SQL using sqlcmd and return stdout
    """
    cmd = [
        "sqlcmd",
        "-S", db_conf["server"],
        "-d", db_conf["database"],
        "-U", db_conf["authentication"]["admin_user"],
        "-P", db_conf["authentication"]["admin_password"],
        "-b"  # stop on error
    ]

    proc = subprocess.run(
        cmd + ["-Q", sql_text],
        capture_output=True,
        text=True
    )

    if proc.returncode != 0:
        raise RuntimeError(f"SQL execution failed:\n{proc.stderr}")

    return proc.stdout


def append_csv(csv_path, row_dict):
    """
    Append one row to CSV.
    Create file + header if not exists.
    """
    csv_path = Path(csv_path)
    csv_path.parent.mkdir(parents=True, exist_ok=True)

    file_exists = csv_path.exists()

    with open(csv_path, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=row_dict.keys())

        if not file_exists:
            writer.writeheader()

        writer.writerow(row_dict)


def enrich_row(row, db_conf, policy_meta=None, query_meta=None):
    enriched = dict(row)

    enriched["machine"] = db_conf["machine"]["label"]

    if policy_meta:
        enriched["policy_id"] = policy_meta.get("policy_id")
        enriched["policy_name"] = policy_meta.get("policy_name")
        enriched["predicate_function"] = policy_meta.get("predicate_name")
        enriched["predicate_columns"] = ",".join(policy_meta.get("columns", []))
        enriched["table_affected"] = policy_meta.get("table")

    if query_meta:
        enriched["query_name"] = query_meta.get("query_name")
        enriched["tables_used"] = ",".join(query_meta.get("tables", []))

    return enriched

