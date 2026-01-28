import re


def parse_stats(output):
    cpu_ms = None
    elapsed_ms = None
    logical_reads = 0
    rows_returned = None
    errors = None

    for line in output.splitlines():

        # TIME
        if "CPU time" in line and "elapsed time" in line:
            cpu_match = re.search(r"CPU time = (\d+)", line)
            elapsed_match = re.search(r"elapsed time = (\d+)", line)

            if cpu_match:
                cpu_ms = int(cpu_match.group(1))
            if elapsed_match:
                elapsed_ms = int(elapsed_match.group(1))

        # IO
        if "logical reads" in line:
            lr_match = re.search(r"logical reads (\d+)", line)
            if lr_match:
                logical_reads += int(lr_match.group(1))

        # ROW COUNT (sqlcmd prints "(X rows affected)")
        if "rows affected" in line:
            row_match = re.search(r"\((\d+) rows affected\)", line)
            if row_match:
                rows_returned = int(row_match.group(1))


        # ERRORS
        if "Msg " in line or "Error" in line:
            errors = line


    return {
        "cpu_ms": cpu_ms,
        "elapsed_ms": elapsed_ms,
        "logical_reads": logical_reads,
        "rows_returned": rows_returned,
        "errors": errors
    }
