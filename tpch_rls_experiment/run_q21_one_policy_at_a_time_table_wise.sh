QUERY_FILE="21.sql"
PREDICATES_DIR="predicates/lineitem"

for json_file in "$PREDICATES_DIR"/*.json; do
    if [ -f "$json_file" ]; then
        json_name=$(basename "$json_file")
        echo "-------------------------------------------"
        echo "Running policy: lineitem:$json_name"
        echo "-------------------------------------------"

        python3 -m experiments.mode2_query_with_predicates \
            "$QUERY_FILE" \
            "lineitem:$json_name"
    fi
done
