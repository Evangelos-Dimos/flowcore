#!/bin/bash

source ../config/db.conf

LOG_FILE="../logs/system.log"

echo "------ INVENTORY ------"

docker exec -i $DB_CONTAINER sqlplus -s $DB_USER/$DB_PASSWORD@$DB_SERVICE <<EOF

SET LINESIZE 150
SET PAGESIZE 50
SET FEEDBACK OFF
SET HEADING ON

COLUMN product_name FORMAT A25
COLUMN product_type FORMAT A15
COLUMN location_id FORMAT A15
COLUMN quantity FORMAT 9999

SELECT
    p.name AS product_name,
    i.product_type,
    i.location_id,
    i.quantity_number AS quantity
FROM inventory i
JOIN products p ON i.product_id = p.product_id
ORDER BY i.location_id;

EXIT;
EOF

# check if command failed
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to fetch inventory" >> "$LOG_FILE"
    echo "Error retrieving inventory"
    exit 1
fi

echo "-----------------------"
