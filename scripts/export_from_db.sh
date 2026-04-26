#!/bin/bash

source "$(dirname "$0")/docker.sh"

# Create tmp directory if not exists
mkdir -p ../tmp

echo "[INFO] Exporting inventory to CSV..." >> "$LOG_FILE"

# Export products (product_id, name, product_type, quantity)
call_database "SELECT product_id || ',' || name || ',' || product_type || ',' || quantity FROM products;" > ../tmp/inventory_export.csv

# Export order items (order_id, product_id, quantity)
call_database "SELECT order_id || ',' || product_id || ',' || quantity FROM order_items;" > ../tmp/order_items_export.csv

# Export locations (location_id, max_capacity, current_count)
call_database "SELECT location_id || ',' || max_capacity || ',' || current_count FROM locations;" > ../tmp/locations_export.csv

echo "[INFO] Export complete" >> "$LOG_FILE"
echo ""
echo "=== EXPORT COMPLETE ==="
echo "inventory_export.csv: $(wc -l < ../tmp/inventory_export.csv) lines"
echo "order_items_export.csv: $(wc -l < ../tmp/order_items_export.csv) lines"
echo "locations_export.csv: $(wc -l < ../tmp/locations_export.csv) lines"
