#!/bin/bash


# python3 -m experiments.mode2_query_with_predicates 1.sql lineitem:p11_customer_supplier_same_region.json orders:p13_orders_customer_europe.json customer:p14_customer_asia_balance.json supplier:p18_supplier_brushed_copper.json part:p20_part_avg_supplycost.json

# Exit immediately if any command fails
set -e

# Base command
BASE_CMD="python3 -m experiments.mode2_query_with_predicates"

# Predicate list (fixed across all queries)
PREDICATES=(
  "lineitem:p11_customer_supplier_same_region.json"
  "orders:p13_orders_customer_europe.json"
  "customer:p14_customer_asia_balance.json"
  "supplier:p18_supplier_brushed_copper.json"
  "part:p20_part_avg_supplycost.json"
)

# Loop through queries 1.sql to 22.sql
for i in {1..22}
do
    QUERY_FILE="${i}.sql"

    echo "=============================================="
    echo "Running MODE2_EXPLICIT for query: ${QUERY_FILE}"
    echo "=============================================="

    # Check if query file exists
    if [ ! -f "queries/${QUERY_FILE}" ]; then
        echo "Query file not found: queries/${QUERY_FILE}"
        echo "Skipping..."
        continue
    fi

    # Run the command
    ${BASE_CMD} "${QUERY_FILE}" "${PREDICATES[@]}"

    echo "Finished ${QUERY_FILE}"
    echo
done

echo "All MODE2_EXPLICIT runs completed."
