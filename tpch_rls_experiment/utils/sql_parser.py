import re

def extract_tables(sql_text):
    """
    Extract all table names referenced as dbo.<table>
    Works for nested queries, subqueries, EXISTS, IN, JOIN, FROM, etc.
    """

    tables = set()

    # Normalize whitespace
    sql = re.sub(r"\s+", " ", sql_text)

    # Find dbo.<table_name>
    matches = re.findall(
        r"\bdbo\.([a-zA-Z_][a-zA-Z0-9_]*)",
        sql,
        flags=re.IGNORECASE
    )

    for t in matches:
        tables.add(t.lower())

    return sorted(tables)
