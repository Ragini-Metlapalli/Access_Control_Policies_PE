import re


def extract_tables(sql_text):
    """
    Extract table names from FROM and JOIN clauses.
    Returns a list of lowercase table names.
    """

    tables = set()

    patterns = [
        r"\bFROM\s+([a-zA-Z_][a-zA-Z0-9_]*)",
        r"\bJOIN\s+([a-zA-Z_][a-zA-Z0-9_]*)"
    ]

    for pattern in patterns:
        for match in re.findall(pattern, sql_text, flags=re.IGNORECASE):
            tables.add(match.lower())

    return list(tables)
