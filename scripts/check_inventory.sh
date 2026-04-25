#!/bin/bash

source "$(dirname "$0")/docker.sh"

echo "=========================================="
echo "CURRENT INVENTORY"
echo "=========================================="
echo ""

echo "--- Products ---"
call_database "SELECT product_id, name, product_type, quantity FROM products ORDER BY product_id;"

echo ""
echo "--- Locations ---"
call_database "SELECT location_id, max_capacity, current_count FROM locations ORDER BY location_id;"

echo ""
echo "--- Inventory ---"
call_database "SELECT product_id, location_id, quantity_number FROM inventory ORDER BY location_id, product_id;"

echo ""
echo "=========================================="
echo "SUMMARY"
echo "=========================================="

# get totals
TOTAL_ITEMS=$(call_database "SELECT SUM(quantity) FROM products;")
TOTAL_ITEMS=$(echo "$TOTAL_ITEMS" | tr -d '[:space:]')

TOTAL_OCCUPIED=$(call_database "SELECT SUM(current_count) FROM locations;")
TOTAL_OCCUPIED=$(echo "$TOTAL_OCCUPIED" | tr -d '[:space:]')

TOTAL_CAPACITY=$(call_database "SELECT SUM(max_capacity) FROM locations;")
TOTAL_CAPACITY=$(echo "$TOTAL_CAPACITY" | tr -d '[:space:]')

echo "Total items in warehouse: $TOTAL_ITEMS"
echo "Occupied space: $TOTAL_OCCUPIED"
echo "Total capacity: $TOTAL_CAPACITY"

if [ -n "$TOTAL_CAPACITY" ] && [ "$TOTAL_CAPACITY" -gt 0 ]; then
    UTILIZATION=$(echo "scale=2; $TOTAL_OCCUPIED * 100 / $TOTAL_CAPACITY" | bc)
    echo "Utilization: ${UTILIZATION}%"
fi

echo "[INFO] Inventory report generated" >> "$LOG_FILE"
