#!/bin/bash
# export_tables.sh

source "$(dirname "$0")/docker.sh"

# Create tmp directory if not exists
mkdir -p ../tmp

echo "=== EXPORTING TABLES TO CSV ==="
echo ""

# Export each table
for table in customers products locations inventory orders order_items; do
    echo -n "  Exporting $table... "
    export_to_csv "$table" "../tmp/${table}_export.csv"
    if [ -s "../tmp/${table}_export.csv" ]; then
        lines=$(wc -l < "../tmp/${table}_export.csv")
        echo "✓ ($lines rows)"
    else
        echo "✗ (empty or failed)"
    fi
done

echo ""
echo "=== EXPORT COMPLETE ==="
echo "Files saved in ../tmp/"
ls -lh ../tmp/*_export.csv 2>/dev/null