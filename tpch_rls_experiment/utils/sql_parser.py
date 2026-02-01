import re

def extract_tables(sql_text):
    """
    Extract table names from:
    - FROM a, b, c
    - JOIN a
    Returns lowercase table names without schema
    """
    tables = set()

    # Normalize whitespace
    sql = re.sub(r"\s+", " ", sql_text)

    # Handle FROM ... (comma-separated)
    from_match = re.search(r"\bFROM\s+(.+?)(\bWHERE\b|\bGROUP\b|\bORDER\b|$)", sql, re.IGNORECASE)
    if from_match:
        from_part = from_match.group(1)
        for chunk in from_part.split(","):
            name = chunk.strip().split()[0]
            tables.add(name.split(".")[-1].lower())

    # Handle JOIN ...
    for match in re.findall(r"\bJOIN\s+([a-zA-Z0-9_.]+)", sql, re.IGNORECASE):
        tables.add(match.split(".")[-1].lower())

    return list(tables)
