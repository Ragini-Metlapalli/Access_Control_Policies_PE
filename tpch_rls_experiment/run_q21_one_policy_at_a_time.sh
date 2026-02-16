#!/bin/bash

QUERY_FILE="21.sql"
PREDICATES_DIR="predicates"

# Loop over each table folder
for table in "$PREDICATES_DIR"/*; do
    if [ -d "$table" ]; then
        table_name=$(basename "$table")

        # Loop over each json file inside table folder
        for json_file in "$table"/*.json; do
            if [ -f "$json_file" ]; then
                json_name=$(basename "$json_file")

                echo "-------------------------------------------"
                echo "Running policy: $table_name:$json_name"
                echo "-------------------------------------------"

                python3 -m experiments.mode2_query_with_predicates \
                    "$QUERY_FILE" \
                    "${table_name}:${json_name}"
            fi
        done
    fi
done
