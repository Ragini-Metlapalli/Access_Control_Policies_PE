#!/bin/bash

# Usage:
# ./merge_csv.sh output.csv input1.csv input2.csv input3.csv ...
# or
# ./merge_csv.sh merged.csv results/*.csv

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 output.csv input1.csv input2.csv ..."
    exit 1
fi

OUTPUT_FILE="$1"
shift   # remove output file from arguments

FIRST_FILE=true

# Clear output file if exists
> "$OUTPUT_FILE"

for FILE in "$@"; do
    if [ ! -f "$FILE" ]; then
        echo "Skipping missing file: $FILE"
        continue
    fi

    if $FIRST_FILE; then
        # Copy entire first file (including header)
        cat "$FILE" >> "$OUTPUT_FILE"
        FIRST_FILE=false
    else
        # Skip first line (header) and append rest
        tail -n +2 "$FILE" >> "$OUTPUT_FILE"
    fi
done

echo "Merged files into $OUTPUT_FILE"
